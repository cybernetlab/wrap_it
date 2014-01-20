require 'spec_helper'

describe WrapIt::TextContainer do
  it 'renders body' do
    render '<%= helper "text" %>'
    expect(rendered).to have_tag 'p', text: 'text'
  end

  it 'places body from options prior to captured content' do
    render '<%= helper "text" do %> with content<% end %>'
    expect(rendered).to have_tag 'p', text: 'text with content'
  end
end
