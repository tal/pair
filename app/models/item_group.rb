module ItemGroups;end
include ItemGroups

class ItemGroup
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :description, type: String
  field :key, type: String
  index :key, unique: true
  field :cnt, type: Integer, default: 0

  validates_presence_of :key

  after_initialize :item_class
  after_create :item_class


  ITEM_CLASSES = Hash.new do |h,k|
    name = "#{k}_item"
    klass = ItemGroups.const_set(name.classify,Class.new(Item))
    klass.store_in name.pluralize
    klass.instance_variable_set "@item_group_key", k
    h[k] = klass
  end

  def new_vote
    v = Vote.new(item_type: self.item_class.to_s)
    v.item_class
    v
  end

  def item_class
    unless key.blank? || new?
      ITEM_CLASSES[key]
    end
  end
  
  def items
    item_class.all
  end

  class << self
    def [] key
      self.where(key: key).first
    end
  end

  class CantMakePairCollection < StandardError; end
end
