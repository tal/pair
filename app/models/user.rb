class User
  include Mongoid::Document
  field :current_vote, type: Hash, default:{}

  after_initialize do
    @get_vote = {}
  end

  # TODO: Consider caching this in an instance variable
  def get_vote group_key
    Vote.find(current_vote[group_key]) if current_vote[group_key]
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

end
