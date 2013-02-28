require 'spec_helper'

describe Page do
  
  let(:valid_page) { Page.new name: "Valid_Page", title: "Valid Title", text: "Some Valid Text" }

  it 'is invalid without name, title and text' do
    subject.should_not be_valid
  end

  context "formatting" do

    it 'should format some bold text' do
      valid_page.text = "**bold text**"
      valid_page.formatted_text.should be_eql("<b>bold text</b>")
    end
   
    it 'should format some italic text' do
      valid_page.text = "\\\\italic text\\\\"
      valid_page.formatted_text.should be_eql("<i>italic text</i>")
    end

    it 'should format some hyperlink' do
      valid_page.save
      valid_page.text = "((Valid_Page Some Hyperlink Text))"
      valid_page.formatted_text.should be_eql("<a href='/Valid_Page'>Some Hyperlink Text</a>")
    end
  end
   
  #pending "add some examples to (or delete) #{__FILE__}"
end
