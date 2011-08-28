require 'spec_helper'

describe User do
  before :all do
    @user = User.create
  end

  context "#get_vote" do
    before :all do
      @ig = ItemGroup.create!(key: "user_test")
      @i1 = @ig.item_class.create(value: 'one')
      @i2 = @ig.item_class.create(value: 'two')
      @ig.item_class.update_item_pair_set

      @v = @ig.new_vote
      @v.user = @user
      @v.add_item(@i1,@i2)
      @v.save!
    end

    it "should get the current vote for a key" do
      @user.get_vote('asdfasdfs').should be_nil
    end

    it "should get current vote for a key" do
      @user.get_vote(@ig.key).should == @v
    end

    it "should find vote" do
      @user.find_vote(@i1,@i2).should == @v
    end

  end

  context "#get_or_create_vote" do
    before :all do
      @ig = ItemGroup.create!(key: "user_two_test")
      @i1 = @ig.item_class.create(value: 'one')
      @i2 = @ig.item_class.create(value: 'two')
      @ig.item_class.update_item_pair_set
    end

    it "should create a key the first time" do
      v = @user.get_or_create_vote(@ig.key)
      v.should be_a Vote
      v.should_not be_new
    end

    it "should " do
      v = @user.get_or_create_vote(@ig.key)
      @user.get_or_create_vote(@ig.key).should == v
    end

    it "should foo" do
      ItemGroup.create!(key: "asdfasdfasfd")
      v = @user.get_or_create_vote('asdfasdfasfd')
      v.should == nil
    end

  end

end
