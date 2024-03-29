class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_presence_of :value

  field :_id, type: Integer
  field :active, type: Boolean, default: true
  index :active
  field :vote_count, type: Integer, default: 0
  field :up_votes, type: Integer, default: 0
  field :down_votes, type: Integer, default: 0
  field :skips, type: Integer, default: 0
  
  field :value, type: String

  TYPE_REGEX = Typed::Group.new({
      youtube: [
        /\.youtube\..+\/watch\?.*v=([a-zA-Z0-9]{11})/#http://www.youtube.com/watch?v=1wYNFfgrXTI&feature=feedrec
      ],
      image: [
        /\.(?:jpeg|jpg|png|gif)$/i
      ]
    })
  
  before_create :set_id

  belongs_to :user

  has_many :votes, as: :votable

  named_scope :visible, where: {active: true}

  after_create do
    self.class.update_item_pair_set
    item_group.inc(:cnt,1)
  end

  def disable
    self.active = false
    item_group.cnt = item_group.cnt-1 and item_group.save
    save
  end

  def detect_type
    @detect_type ||= TYPE_REGEX.match(value)
  end

  def youtube?
    detect_type.type == :youtube if detect_type
  end

  def image?
    detect_type.type == :image if detect_type
  end

  def button_text
    detect_type ? 'Pick' : value
  end
  
  def score
    up_votes/vote_count.to_f
  end

  def score_pct
    (score*100).round(2)
  end

  def group_key
    self.class.item_group_key
  end
  
  def item_group(force=false)
    self.class.item_group(force)
  end

  def fb_image
    if image?
      value
    else
      'https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png'
    end
  end

private

  def set_id
    self._id = item_group.get_new_item_id
  end

  PAIR_SEPARATOR = ','
  class << self
    def redis
      @redis ||= Redis::Namespace.new(item_group_key, :redis => REDIS)
    end

    def model_name
      @_model_name ||= ActiveModel::Name.new(Item)
    end

    attr_reader :item_group_key
    def item_group force=false
      @item_group = nil if force
      @item_group ||= ItemGroup.where(key: item_group_key).first
    end

    def generate_item_pair_set
      items = only(:_id).all
      
      sets = []

      items.each do |i|
        items.each do |ii|
          if ii.id > i.id
            sets << [i.id.to_s(36),ii.id.to_s(36)].join(PAIR_SEPARATOR)
          end
        end
      end
      sets
    end

    def pair_set_key
      "pairs"
    end

    def user_pairs user_id
      redis.smembers(user_id)
    end

    def user_pair user_id
      key = "temp:#{user_id}"<<pair_set_key
      redis.sdiffstore key, pair_set_key, user_id
      pair = redis.spop key

      redis.multi do
        redis.del key
        redis.sadd user_id, pair
      end
      
      if pair
        key1,key2 = pair.split(PAIR_SEPARATOR)

        return key1.to_i(36), key2.to_i(36)
      else
        return []
      end
    end

    def random_pair
      redis.srandmember(pair_set_key).split(PAIR_SEPARATOR).collect{|key| key.to_i(36)}
    end

    def user_item_pair user_id
      key1, key2 = user_pair(user_id)
      return where(_id:key1).first, where(_id:key2).first
    end

    def item_pair_set
      redis.smembers(pair_set_key)
    end

    def update_item_pair_set
      redis.multi do
        key = "temp:"<<pair_set_key

        generate_item_pair_set.each do |s|
          redis.sadd key, s
        end

        redis.rename key, pair_set_key
      end
    end
  end
end
