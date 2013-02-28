require 'spec_helper'

describe "pages/index" do
  before(:each) do
#    assign(:pages, [
#      stub_model(Page,
#        :name => "Parent_Name",
#        :title => "Title",
#        :text => "Text",
#      ),
#      stub_model(Page,
#        :name => "Child_Name",
#        :title => "Title",
#        :text => "Text"
#      )
#    ])
    @page1 = Page.new name: "First_Page", title: "My Title", text: "My Text"
    @page2 = Page.new name: "Second_Page", title: "My Title", text: "My Text"
    @page1.save
    @page2.save
    @tree = Page.tree
  end

  it "renders a list of pages" do
    render
    rendered.should have_selector 'a', href: @page1.url, content: "First_Page"
    rendered.should have_selector 'a', href: @page2.url, content: "Second_Page"
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "a"
    #assert_select "a"
  end
end
