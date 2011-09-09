class User
  include Mongoid::Document
  field :current_vote, type: Hash, default:{}
  embeds_one :fb_session
  index 'fb_session.uid', unique: true, sparse: true

  # TODO: Consider caching this in an instance variable
  def get_vote group_key
    Vote.find(current_vote[group_key]) if current_vote[group_key]
  end

  def admin?
    id == BSON::ObjectId('4e658c340e2672000100002b')
  end

  def get_or_create_vote group_key
    return get_vote(group_key) if get_vote(group_key)

    if ig = ItemGroup[group_key]
      if v = ig.new_vote
        v.user = self

        keys = ig.item_class.user_pair(self.id)
        return if keys.empty?
        v.add_item(*keys)
        v.save!
        return v
      end # /if v
    end # /if ig
  end

  def find_vote item1, item2
    raise "Both items must be from same group" if item1.class != item2.class
    dset = Vote.all_in('vote_items._id' => [item1.id,item2.id])
    dset.and(item_type: item1.class, user_id:self.id).first
  end

  class << self
    def [] uid
      where('fb_session.uid' => uid).first
    end
  end
end
