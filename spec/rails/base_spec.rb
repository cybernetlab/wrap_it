require 'spec_helper'

=begin
class UsersHelperTest < ActionView::TestCase
  it 'includes framework-specific methods' do
    methods = successor_class.protected_instance_methods(true)
    expect(methods).to include :concat, :capture, :output_buffer
  end

  it 'renders base as div' do
    render '<%= successor %>'
    expect(rendered).to have_tag 'div', count: 1
  end

  it 'captures block content' do
    render '<%= successor do %>Some text<% end %>'
    expect(rendered).to have_tag 'div', count: 1, text: /Some text/
  end
end
=end
