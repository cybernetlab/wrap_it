require 'spec_helper'

describe WrapIt::Container do
  before do
    successor_class.class_eval do
      default_tag 'ul'
      child :item, tag: 'li'
    end
  end

  def list_erb(args = '')
    <<-EOL
      <%= helper(#{args}) do |s| %>
        <li class="c1">item 1</li>
        <% 2.upto 5 do |i| %>
        <%= s.item class: "c\#{i}" do |_| %>item <%= i %><% end %>
        <% end %>
        <li class="c6">item 6</li>
      <% end %>
    EOL
  end

  it 'renders as ul' do
    render '<%= helper %>'
    expect(rendered).to have_tag 'ul', count: 1
    expect(rendered).to_not have_tag 'ul > *'
  end

  it 'renders child items' do
    render list_erb
    expect(rendered).to have_tag 'ul > li', count: 6
  end

  it 'renders child items deffered' do
    render list_erb(':deffered_render')
    expect(rendered).to have_tag 'ul > li', count: 6
  end

  it 'drops content child items with omit_content' do
    successor_class.class_eval { omit_content }
    render list_erb
    expect(rendered).to have_tag 'ul > li', count: 4
  end

  it 'drops content childs with omit_content and deffered' do
    successor_class.class_eval { omit_content }
    render list_erb(':deffered_render')
    expect(rendered).to have_tag 'ul > li', count: 4
  end

  describe 'child helper method safety' do
    it 'returns string with default options' do
      expect(successor.item).to be_kind_of String
    end

    it 'returns string with omit_content' do
      successor_class.class_eval { omit_content }
      expect(successor.item).to be_kind_of String
    end

    it 'returns string with deffered' do
      expect(successor(:deffered_render).item).to be_kind_of String
    end

    it 'returns string with deffered and omit' do
      successor_class.class_eval { omit_content }
      expect(successor(:deffered_render).item).to be_kind_of String
    end
  end

  it 'not collects children without deffered_render' do
    successor.item
    expect(successor.children.size).to eq 0
  end

  it 'collects children with deffered_render' do
    successor(:deffered_render).item
    expect(successor.children.size).to eq 1
  end

  it 'avoids changing deffered_render after first item added' do
    successor(:deffered_render).item
    successor.deffered_render = false
    expect(successor.deffered_render?).to be_true
  end

  it 'extracts one child from optioins' do
    successor_class.class_eval { child :item1, tag: 'li', option: true }
    render '<%= helper item1: {class: "listitem"} %>'
    expect(rendered).to have_tag 'ul > li.listitem', count: 1
  end
end
