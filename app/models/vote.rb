class Vote
  include Mongoid::Document

  field :winner_id, type: Integer
  field :skipped,   type: Boolean, default: false
  field :item_type, type: String

  belongs_to :user

  embeds_many :vote_items

  def picked item
    if item.is_a?(Item)
      item = item.id
    elsif item.is_a?(VoteItem)
      item = item.item_id
    end

    if item_ids.include?(item)
      self.winner_id = item
    else
      false
    end
  end

  validate do
    errors.add(:whatever, 'yoyo') if items.size < 2
  end

  def picked! item
    save if picked(item)
  end

  def winner
    vote_items.to_a.find do |vi|
      vi.item_id == winner_id
    end.try(:item)
  end

  def won?
    !winner_id.nil?
  end

  def completed?
    won? || skipped
  end

  def items
    @items ||= vote_items.collect {|vi| vi.item}
  end

  def item_ids
    vote_items.collect {|vi| vi.item_id}
  end

  def item_class
    CONSTANTS[item_type] if item_type
  end

  class << self
    

    # Oh god this is ugly
    def for_key_and_user key, user
      if user.current_vote[key]
        return Vote.where(_id:user.current_vote[key]).first
      end

      ig = ItemGroup[key]
      
      if ig
        v = ig.new_vote
        
        if v
          v.user = user

          keys = ig.item_class.user_pair(user.id)
          v.vote_items.build(item_id:keys.pop)
          v.vote_items.build(item_id:keys.pop)

          # puts v.item_class
          if v.save
            user.current_vote[key] = v.id
          end
          return v
        end
      end

    end

  end
end

class VoteItem
  include Mongoid::Document
  embedded_in :vote

  field :item_id, type: Integer

  validates_presence_of :item

  def item
    @item ||= vote.item_class.where(_id: item_id).first
  end
end
