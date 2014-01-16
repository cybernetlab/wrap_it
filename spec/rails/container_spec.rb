require 'spec_helper'

describe WrapIt::Container do
  before do
    successor_class.class_eval do
      default_tag 'ul'
      child :item, [tag: 'li']
    end
    Object.send(:const_set, :Successor, successor_class)
  end

  it 'renders as ul' do
    render '<%= successor_helper %>'
    expect(rendered).to have_tag 'ul', count: 1
    expect(rendered).to_not have_tag 'ul > *'
  end

  it 'renders child items' do
    render <<-EOL
      <%= successor_helper do |s| %>
        <li class="c1">item 1</li>
        <% 2.upto 5 do |i| %>
        <%= s.item class: "c\#{i}" do |_| %>item <%= i %><% end %>
        <% end %>
        <li class="c6">item 6</li>
      <% end %>
    EOL
    expect(rendered).to have_tag 'ul > li', count: 6
  end
end
