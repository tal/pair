require 'spec_helper'

describe "Items" do
  describe "GET /items" do
    before :all do
      @ig = ItemGroup.create(key: 'items_controller_request')
    end

    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get items_path(group_key: @ig.key)
      response.status.should be(200)
    end
  end
end
