require 'spec_helper'

describe "pages/new" do
  before(:each) do
    @page = Page.new name: "MyStringName", title: "My Title", text: "My Text" 
    #assign(:page, stub_model(Page,
    #  :name => "MyStringNewTest",
    #  :title => "MyString",
    #  :text => "MyString"
    #).as_new_record)
  end

  it "renders new page form" do
    render

    rendered.should have_selector "input", id: "page_name",  name: "page[name]"
    rendered.should have_selector "input", id: "page_title",  name: "page[title]"
    rendered.should have_selector "textarea", id: "page_text",  name: "page[text]"
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "form", :action => @page.url, :method => "post" do
    #  assert_select "input#page_name", :name => "page[name]"
    #  assert_select "input#page_title", :name => "page[title]"
    #  assert_select "input#page_text", :name => "page[text]"
    #end
  end
end
