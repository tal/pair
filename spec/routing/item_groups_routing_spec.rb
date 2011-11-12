require "spec_helper"

describe ItemGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/questions").should route_to("item_groups#index")
    end

    it "routes to #new" do
      get("/questions/new").should route_to("item_groups#new")
    end

    it "routes to #show" do
      get("/questions/1").should route_to("item_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/questions/1/edit").should route_to("item_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/questions").should route_to("item_groups#create")
    end

    it "routes to #update" do
      put("/questions/1").should route_to("item_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/questions/1").should route_to("item_groups#destroy", :id => "1")
    end

  end
end
