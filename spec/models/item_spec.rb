require 'spec_helper'

describe Item do
  before(:all) do 
    @ig = ItemGroup.create(key: 'test_one')
    TestOneItem.create! value: 'second'
    TestOneItem.create! value: 'three'
  end
  
  it "should create a new item" do
    i = TestOneItem.create! value: 'first'
    i.new?.should be false
  end
  
  it "should calculate score" do
    i = TestOneItem.create! value: 'first',
                            vote_count: 3,
                            up_votes: 1,
                            down_votes: 1,
                            skips: 1
    
    i.score.should == 1/3.0
  end

  it "should auto increment the id" do
    ii = TestOneItem.last
    i = TestOneItem.create! value: 'second'
    i._id.should == ii._id+1
  end

  it "should belong to defined group" do
    i = TestOneItem.create! value: 'first'
    i.group_key.should == @ig.key
  end

  it "should build an item pair set" do
    pending "how to figure out how many pairs there should be"
    TestOneItem.generate_item_pair_set.should have(3).item_pairs
  end

  it "should set the redis keys" do
    TestOneItem.update_item_pair_set
    TestOneItem.item_pair_set.should_not be_empty
    TestOneItem.item_pair_set.should =~ TestOneItem.generate_item_pair_set
    TestOneItem.create! value: 'third'
    TestOneItem.update_item_pair_set
    TestOneItem.item_pair_set.should =~ TestOneItem.generate_item_pair_set
  end

  context "#detect_type" do
    it "should detect youtube" do
      i = Item.new(value: 'http://www.youtube.com/watch?v=1wYNFfgrXTI&feature=feedrec')
      i.should be_youtube
    end

    it "should detect image" do
      i = Item.new(value: 'http://imager.com/foo.jpg')
      i.should be_image
    end
  end

  it "should get random keys" do
    TestOneItem.create! value: 'first'
    TestOneItem.create! value: 'second'
    TestOneItem.random_pair.should have(2).keys
  end

  it "should not return the same pair twice" do
    user_id = 'asdf123'
    TestOneItem.redis.del user_id
    sets = []
    times = 0
    total = TestOneItem.generate_item_pair_set.size
    begin
      set = TestOneItem.user_pair(user_id)
      sets << set unless set.empty?
      times += 1
      times.should <= total+1
    end until set.empty?

    sets.should have(total).sets
  end
end
