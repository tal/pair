class Vote
  include Mongoid::Document

  field :winner_id, type: Integer
  field :skipped,   type: Boolean, default: false
  field :item_type, type: String

  belongs_to :user

  embeds_many :vote_items

  def picked item
    if item.is_a?(Item) || item.is_a?(VoteItem)
      item = item.id
    end

    if item_ids.include?(item)
      self.winner_id = item
    else
      false
    end
  end

  validate do
    errors.add(:invalid_number_of_items, 'must have two items') if items.size != 2
    if user && user.current_vote[item_type]
      errors.add(:user_has_vote, "user already has a vote for this type")
    end
  end
  validates_presence_of :user

  after_save :set_for_user

  def picked! item
    save if picked(item)
  end

  def winner
    vote_items.to_a.find do |vi|
      vi.id == winner_id
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
    vote_items.collect {|vi| vi.id}
  end

  def item_class
    CONSTANTS[item_type] if item_type
  end

  def set_for_user
    user.current_vote[item_class.item_group_key] = self.id
    user.save
  end

  def add_item *items
    @items = nil

    items.each do |item|
      vi = VoteItem.new
      item = item.is_a?(Item) ? item.id : item
      vi.id = item
      if vote_items.first && vote_items.first.id > item
        vote_items.unshift(vi)
      else
        vote_items.push(vi)
      end
    end
  end

  class << self

  end
end

class VoteItem
  include Mongoid::Document
  embedded_in :vote

  field :id, type: Integer

  validates_presence_of :item

  def item
    @item ||= vote.item_class.where(_id: id).first
  end
end
