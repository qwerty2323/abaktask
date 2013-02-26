require 'spec_helper'

describe "pages/index" do
  before(:each) do
    assign(:pages, [
      stub_model(Page,
        :name => "Name",
        :full_path => "Full Path",
        :title => "Title",
        :text => "Text",
        :formatted_text => "Formatted Text"
      ),
      stub_model(Page,
        :name => "Name",
        :full_path => "Full Path",
        :title => "Title",
        :text => "Text",
        :formatted_text => "Formatted Text"
      )
    ])
  end

  it "renders a list of pages" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Full Path".to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "Text".to_s, :count => 2
    assert_select "tr>td", :text => "Formatted Text".to_s, :count => 2
  end
end
