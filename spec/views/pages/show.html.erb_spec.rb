require 'spec_helper'

describe "pages/show" do
  before(:each) do
    @page = assign(:page, stub_model(Page,
      :name => "Name",
      :full_path => "Full Path",
      :title => "Title",
      :text => "Text",
      :formatted_text => "Formatted Text"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Full Path/)
    rendered.should match(/Title/)
    rendered.should match(/Text/)
    rendered.should match(/Formatted Text/)
  end
end
