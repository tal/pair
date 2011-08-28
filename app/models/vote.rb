class Vote
  include Mongoid::Document

  field :winner_id, type: Integer
  field :skipped,   type: Boolean, default: false
  field :item_type, type: String

  belongs_to :user

  embeds_many :vote_items

  validate do
    errors.add(:vote_items, 'must have two items') if items.size != 2
    if user && user.current_vote[item_type]
      errors.add(:user_has_vote, "user already has a vote for this type")
    end

    if winner_id && !item_ids.include?(winner_id)
      errors.add(:winner_id, 'winner must be one of the items')
    end
  end
  validates_presence_of :user

  after_save :set_for_user, :update_item_values
  after_validation do
    @winner_id_changed = winner_id_changed?
    @skipped_changed = skipped_changed?
  end

  def picked item
    if item.is_a?(Item) || item.is_a?(VoteItem)
      item = item.id
    end

    self.winner_id = item
  end

  def picked! item
    picked(item)
    save
  end

  def skip!
    self.skipped = true
    save
  end

  def winner
    vote_items.to_a.find do |vi|
      vi.id == winner_id
    end.try(:item)
  end

  def won?
    !winner_id.nil?
  end

  def skipped?
    skipped
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
    user.current_vote[group_key] = self.id
    user.save
  end

  def group_key
    item_class.item_group_key
  end

  def item1
    vote_items[0].try(:id)
  end

  def item2
    vote_items[1].try(:id)
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

  def update_item_values
    return unless @winner_id_changed == true || (@skipped_changed == true && skipped)
    
    items.each {|i| i.vote_count += 1}

    if @winner_id_changed == true
      items.each do |i|
        if i.id == winner_id
          i.up_votes += 1
        else
          i.down_votes += 1
        end
      end
    elsif (@skipped_changed == true && skipped)
      items.each {|i| i.skips += 1}
    end

    items.each {|i| i.save}
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
