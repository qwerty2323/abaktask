require "spec_helper"

describe PagesController do
  before(:each) do
    @page = Page.new name: "Simple_Valid_Title", title: "My New Title", text: "And Some Text"
    @page.save
  end

  describe "routing" do

    it "routes to #index" do
      get("/").should route_to("pages#index")
    end

    it "routes to #new" do
      get("/add").should route_to("pages#new")
    end

    it "routes to #show" do
      get("/Simple_Valid_Title").should route_to("pages#show", :path => "Simple_Valid_Title")
    end

    it "routes to #edit" do
      get("/Simple_Valid_Title/edit").should route_to("pages#edit", :path => "Simple_Valid_Title")
    end

    it "routes to #create" do
      post("/").should route_to("pages#create")
    end

    it "routes to #update" do
      put("/Simple_Valid_Title").should route_to("pages#update", :path => "Simple_Valid_Title")
    end
=begin
    it "routes to #destroy" do
      delete("/pages/1").should route_to("pages#destroy", :id => "1")
    end
=end
  end
end
