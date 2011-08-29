class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  validates_presence_of :value

  field :_id, type: Integer
  field :vote_count, type: Integer, default: 0
  field :up_votes, type: Integer, default: 0
  field :down_votes, type: Integer, default: 0
  field :skips, type: Integer, default: 0
  
  field :value, type: String
  
  before_create :set_id

  belongs_to :user

  has_many :votes, as: :votable

  after_create do
    self.class.update_item_pair_set
  end
  
  def score
    up_votes/vote_count.to_f
  end

  def group_key
    self.class.item_group_key
  end
  
  def item_group(force=false)
    self.class.item_group(force)
  end

private

  def set_id
    self._id = item_group.inc(:cnt,1)
  end

  PAIR_SEPARATOR = ','
  class << self
    def redis
      @redis ||= REDIS
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
