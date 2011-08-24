require 'spec_helper'

describe Vote do
  before :all do
    @ig = ItemGroup.find_or_create_by(key: 'vote_hi')
    @i1 = @ig.item_class.create(value: 'one')
    @i2 = @ig.item_class.create(value: 'two')

    v = Vote.new
    v.item_type = @i1['_type']
    vi1 = v.vote_items.build(item_id: @i1._id)
    vi2 = v.vote_items.build(item_id: @i2._id)
    v.save

    @v = v
  end

  it "should error out if the attempted item doesn't exist" do
    v = @ig.new_vote
    v.vote_items.build(item_id: @i1._id)
    v.vote_items.build(item_id: 123213)
    v.save.should be false
    v.errors.should have(1).error
  end

  it "should error if only one item added" do
    v = @ig.new_vote
    v.vote_items.build(item_id: @i1._id)
    v.save.should be false
    v.errors.should have(1).error
  end

  it "should accept 2 items" do
    vv = Vote.where(_id: @v.id).first
    vv.vote_items.should have(2).items
  end

  it "should get the correct item type" do
    @v.item_class.should == @ig.item_class
  end

  it "should get the correct item from vote item" do
    @v.vote_items.first.item.should == @i1
  end

  it "should get both items" do
    @v.items.should == [@i1,@i2]
  end

  context "getting vote" do
    before :all do
      @ig.item_class.create(value: 'three')
      @ig.item_class.create(value: 'four')
      @ig.item_class.create(value: 'five')
    end

    before do
      @user = User.create
      @vote = Vote.for_key_and_user @ig.key, @user
    end

    it "should return a valid new vote" do
      @vote.user.should == @user
      @vote.should_not be_nil
      @vote.errors.should be_empty
      @vote.should_not be_new
    end

    it "should return the same vote if done again" do
      v = Vote.for_key_and_user @ig.key, @user
      v.should == @vote
    end

  end

  context "picking" do
    before do
      @v.winner_id = nil
      @v.save
    end

    it "should get the winner" do
      @v.winner.should be_nil
      @v.winner_id = @i2.id
      @v.winner.should == @i2
      @v.winner_id = @i1.id
      @v.winner.should == @i1
    end

    it "should pick based on key and id" do
      @v.picked(@i2.id)
      @v.winner.should == @i2
    end

    it "should pick based on item" do
      @v.picked!(@i2)
      @v.winner.should == @i2
    end

    it "should fail if item isnt there" do
      @v.picked!(@i2.id+10).should be nil
      @v.winner.should be nil
    end
  end
end
