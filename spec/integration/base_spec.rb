require 'spec_helper'

describe WrapIt::Base do
  it 'includes framework-specific methods' do
    methods = successor_class.protected_instance_methods(true)
    expect(methods).to include :concat, :capture, :output_buffer
  end

  it 'renders base as div' do
    render '<%= helper %>'
    expect(rendered).to have_tag 'div', count: 1
  end

  describe 'self.omit_content' do
    it 'captures block content' do
      render '<%= helper do %>Some text<% end %>'
      expect(rendered).to have_tag 'div', count: 1, text: /Some text/
    end

    it 'omits block content with omit_content' do
      successor_class.class_eval { omit_content }
      render '<%= helper do %>Some text<% end %>'
      expect(rendered).to have_tag 'div', count: 1, text: ''
    end
  end

  describe '#render' do
    it 'adds content from arguments' do
      expect(
        successor.render('text', :and, ' from arguments')
      ).to have_tag 'div', text: 'text from arguments'
    end

    it 'adds content from block' do
      expect(successor.render { 'text' }).to have_tag 'div', text: 'text'
    end
  end

  describe '#wrap' do
    it 'wraps with WrapIt::Base by default' do
      render '<%= helper(tag: :p) { |s| s.wrap } %>'
      expect(rendered).to have_tag 'div > p'
    end

    it 'wraps with WrapIt::Base and creating options' do
      render '<%= helper(tag: :p) { |s| s.wrap tag: :nav } %>'
      expect(rendered).to have_tag 'nav > p'
    end

    it 'wraps with class and creating options' do
      render <<-EOL
        <% w = Class.new(WrapIt::Base) { switch :sw, html_class: 'act' } %>
        <%= helper(tag: :p) { |s| s.wrap w, :sw, tag: :nav } %>'
      EOL
      expect(rendered).to have_tag 'nav.act > p'
    end

    it 'wraps with block' do
      render <<-EOL
        <%= helper(tag: :p) { |s| s.wrap do
          |w| w.add_html_class 'nav'
        end } %>'
      EOL
      expect(rendered).to have_tag 'div.nav > p'
    end
  end
end
