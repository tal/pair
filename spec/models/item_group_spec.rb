require 'spec_helper'

describe ItemGroup do
  it "should fail to create on non-saved item group" do
    ig = ItemGroup.new
    ig.key = 'foo'
    ig.item_class.should be nil
  end
  
  it "should fail to create a null keyeditem group" do
    ig = ItemGroup.new
    ig.save.should be false
    # ig.item_class be nil
  end
  
  it "should save fine" do
    ig = ItemGroup.new
    ig.key = 'foo'
    ig.save.should be true
  end
  
  context "created" do
    before do
      @ig = ItemGroup.find_or_create_by(key: 'foo')
    end
    
    it "should create an item group class" do
      @ig.item_class.should < Item
    end
    
    it "should set the item group to the item" do
      @ig.item_class.item_group.should == @ig
    end
    
    it "should access items" do
      expect do
        @ig.item_class.create(value: 'asdfasdfasdf')
      end.to change{@ig.item_class.count}.by(1)
    end
    
  end
  
  context "with items" do
    before :all do
      @ig = ItemGroup.find_or_create_by(key: 'foo')
      @item1 = @ig.item_class.create(value: 'asdfadsf')
    end
    
    it "should be able to get all items" do
      @ig.items.should include @item1
    end
  end
end
