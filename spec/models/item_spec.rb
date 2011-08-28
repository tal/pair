require 'spec_helper'

describe Item do
  before(:all) do 
    @ig = ItemGroup.create(key: 'test_one')
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

  it "should " do
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
    TestOneItem.item_pair_set.should_not =~ TestOneItem.generate_item_pair_set
    TestOneItem.update_item_pair_set
    TestOneItem.item_pair_set.should =~ TestOneItem.generate_item_pair_set
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
    end until set.empty? || times > total+2

    sets.should have(total).sets
    times.should == total+1
  end
end
