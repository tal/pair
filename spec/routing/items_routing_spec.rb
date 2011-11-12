require "spec_helper"

describe ItemsController do
  describe "routing" do
    before :all do
      @ig = ItemGroup.new(key: 'items_controller_routing')
    end

    it "routes to #index" do
      get("#{@ig.key}/items").should route_to("items#index", :group_key => @ig.key)
    end

    it "routes to #new" do
      get("#{@ig.key}/items/new").should route_to("items#new", :group_key => @ig.key)
    end

    it "routes to #show" do
      get("#{@ig.key}/items/1").should route_to("items#show", :id => "1", :group_key => @ig.key)
    end

    it "routes to #edit" do
      get("#{@ig.key}/items/1/edit").should route_to("items#edit", :id => "1", :group_key => @ig.key)
    end

    it "routes to #create" do
      post("#{@ig.key}/items").should route_to("items#create", :group_key => @ig.key)
    end

    it "routes to #update" do
      put("#{@ig.key}/items/1").should route_to("items#update", :id => "1", :group_key => @ig.key)
    end

    it "routes to #destroy" do
      delete("#{@ig.key}/items/1").should route_to("items#destroy", :id => "1", :group_key => @ig.key)
    end

  end
end
