require 'spec_helper'

describe "pages/edit" do
  before(:each) do
    @page = assign(:page, stub_model(Page,
      :name => "PageName",
      :title => "Page Title",
      :text => "Page Text"
    ))
  end

  it "renders the edit page form" do
    render

    rendered.should have_selector "input", id: "page_title", name: "page[title]"
    rendered.should have_selector "textarea", id: "page_text", name: "page[text]"
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    #assert_select "form", :action => @page.url, :method => "post" do
    #  assert_select "input#page_title", :name => "page[title]"
    #  assert_select "input#page_text", :name => "page[text]"
    #end
  end
end
