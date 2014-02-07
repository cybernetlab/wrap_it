require 'spec_helper'

describe WrapIt::TextContainer do
  it 'renders body' do
    render '<%= helper "text" %>'
    expect(rendered).to have_tag 'p', text: 'text'
  end

  it 'don\'t places body from options if content present' do
    render '<%= helper "text" do %>with content<% end %>'
    expect(rendered).to have_tag 'p', text: 'with content'
  end
end
