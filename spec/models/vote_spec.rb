require 'spec_helper'

describe Vote do
  before :all do
    @ig = ItemGroup.find_or_create_by(key: 'vote_hi')
    @i1 = @ig.item_class.create(value: 'one')
    @i2 = @ig.item_class.create(value: 'two')
    @i3 = @ig.item_class.create(value: 'three')

    @v = Vote.new
    @v.user = User.new
    @v.item_type = @i1['_type']
    @vi1 = @v.vote_items.build(id: @i1._id)
    @vi2 = @v.vote_items.build(id: @i2._id)
    @v.save!
  end

  it "should error out if the attempted item doesn't exist" do
    v = @ig.new_vote
    v.user = User.new
    v.vote_items.build(id: @i1._id)
    v.vote_items.build(id: 123213)
    v.save.should be false
    v.errors.should have(1).error
  end

  it "should get a dummy vote" do
    v = @ig.dummy_vote
    v.should be_a Vote
    v.should be_new
    v.user = User.new
    v.should be_valid
  end

  it "should error if only one item added" do
    v = @ig.new_vote
    v.user = User.new
    v.vote_items.build(id: @i1._id)
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

  it "should include items" do
    @v.include?(@i1).should == true
    @v.include?(@i2).should == true
    @v.include?(@i3).should == false
    @v.include?(Item.new).should == false
  end

  it "should accept new items" do
    v = @ig.new_vote
    v.user = User.new
    v.add_item(@i1)
    v.add_item(@i2)
    v.vote_items.should have(2).vote_items
    v.should be_valid
  end

  context "picking" do
    before do
      @v = Vote.new
      @v.user = @user = User.new
      @v.item_type = @i1['_type']
      @vi1 = @v.vote_items.build(id: @i1._id)
      @vi2 = @v.vote_items.build(id: @i2._id)
      @v.save!
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

    it "should increment the counter when picked" do
      expect { @v.picked!(@i2) }.to change{@ig.item_class.find(@i2.id).vote_count}.by(1)
    end

    it "should increment the counter when picked" do
      expect { @v.picked!(@i2) }.to change{@ig.item_class.find(@i1.id).vote_count}.by(1)
    end

    it "should increment the counter when picked" do
      expect { @v.picked!(@i2) }.to change{@ig.item_class.find(@i2.id).up_votes}.by(1)
    end

    it "should increment the counter when picked" do
      expect { @v.picked!(@i2) }.to_not change{@ig.item_class.find(@i2.id).down_votes}
    end

    it "should increment the counter when picked" do
      expect { @v.picked!(@i2) }.to_not change{@ig.item_class.find(@i1.id).up_votes}
    end

    it "should increment the counter when picked" do
      expect { @v.picked!(@i2) }.to change{@ig.item_class.find(@i1.id).down_votes}.by(1)
    end

    it "should increment the counter when picked" do
      @user.get_vote(@ig.key).should == @v
      @v.picked!(@i2)
      User.find(@user.id).get_vote(@ig.key).should be nil
    end

    context "skipping" do
      it "should increment the counter when picked" do
        expect { @v.skip! }.to change{@ig.item_class.find(@i1.id).vote_count}.by(1)
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to change{@ig.item_class.find(@i2.id).vote_count}.by(1)
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to change{@ig.item_class.find(@i1.id).skips}.by(1)
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to change{@ig.item_class.find(@i2.id).skips}.by(1)
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to_not change{@ig.item_class.find(@i1.id).up_votes}
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to_not change{@ig.item_class.find(@i1.id).down_votes}
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to_not change{@ig.item_class.find(@i2.id).up_votes}
      end

      it "should increment the counter when picked" do
        expect { @v.skip! }.to_not change{@ig.item_class.find(@i2.id).down_votes}
      end
    end

    it "should fail if item isnt there" do
      @v.picked!(@i2.id+10).should be false
      @v.winner.should be nil
    end
  end
end
