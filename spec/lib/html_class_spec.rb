require 'spec_helper'

describe WrapIt::HTMLClass do
  it_behaves_like 'Base module'

  it 'has self.html_class and #html_class methods' do
    wrapper_class.class_eval { html_class :a, [:b, 'c'] }
    expect(wrapper.html_class).to eq %w(a b c)
    sub_class = Class.new(wrapper_class) { html_class :a, [:d, 'e'] }
    expect(sub_class.new(template).html_class).to eq %w(a d e b c)
  end

  describe '#html_class_prefix' do
    it 'returns empty string by default' do
      expect(wrapper.html_class_prefix).to eq ''
    end

    it 'returns value setted by class method' do
      wrapper_class.class_eval { html_class_prefix 'e-' }
      expect(wrapper.html_class_prefix).to eq 'e-'
    end

    it 'returns derived value' do
      wrapper_class.class_eval { html_class_prefix 'e-' }
      sub_class = Class.new(wrapper_class)
      expect(sub_class.new(template).html_class_prefix).to eq 'e-'
    end
  end

  it 'has #add_html_class with chaining' do
    expect(wrapper.add_html_class(:test).options[:class]).to eq %w(test)
    @wrapper = nil
    expect(wrapper.add_html_class(:a, 'b').options[:class]).to eq %w(a b)
    @wrapper = nil
    expect(
      wrapper.add_html_class(:a, [:b, :c]).options[:class]
    ).to eq %w(a b c)
  end

  it 'has #remove_html_class with chaining' do
    expect(
      wrapper.add_html_class(:a, :b).remove_html_class('a').options[:class]
    ).to eq %w(b)
  end

  it 'has #html_class? method' do
    expect(wrapper.add_html_class(:a1, :b1).html_class?('a1')).to be_true
    expect(wrapper.html_class?(:a1, :b1)).to be_true
    expect(wrapper.html_class?(:a1, :b2)).to be_false
    expect(wrapper.html_class?(:a2)).to be_false
    expect(wrapper.html_class?(/\d+/)).to be_true
    expect(wrapper.html_class?(%w(a1 c1))).to be_true
    expect(wrapper.html_class? { |x| x[0] == 'a' }).to be_true
  end

  it 'has #no_html_class? method' do
    expect(wrapper.add_html_class(:a1, :b1).no_html_class?('a2')).to be_true
    expect(wrapper.no_html_class?(:a2, :b2)).to be_true
    expect(wrapper.no_html_class?(:a1, :b2)).to be_false
    expect(wrapper.no_html_class?(:a1)).to be_false
    expect(wrapper.no_html_class?(/\d+./)).to be_true
    expect(wrapper.no_html_class?(%w(c1 d1))).to be_true
    expect(wrapper.no_html_class? { |x| x[0] == 'c' }).to be_true
  end

  it 'has html_class setter' do
    wrapper.html_class = [:a, :b]
    expect(wrapper.options[:class]).to eq %w(a b)
  end

  describe 'documentation examples' do
    let(:element) { wrapper }

    it 'html_class=' do
      element.html_class = [:a, 'b', ['c', :d, 'a']]
      expect(element.html_class).to eq %w(a b c d)
    end

    it 'add_html_class' do
      element.html_class = 'a'
      element.add_html_class :b, :c, ['d', :c, :e, 'a']
      expect(element.html_class).to include(*%w(a b c d e))
      expect(element.html_class.size).to eq 5
    end

    it 'remove_html_class' do
      element.add_html_class %w(a b c d e)
      element.remove_html_class :b, ['c', :e]
      expect(element.html_class).to eq %w(a d)
    end

    it 'html_class? with Symbol or String' do
      element.html_class = [:a, :b, :c]
      expect(element.html_class?(:a)).to be_true
      expect(element.html_class?(:d)).to be_false
      expect(element.html_class?(:a, 'b')).to be_true
      expect(element.html_class?(:a, :d)).to be_false
    end

    it 'html_class? with Regexp' do
      element.html_class = [:some, :test]
      expect(element.html_class?(/some/)).to be_true
      expect(element.html_class?(/some/, /bad/)).to be_false
      expect(element.html_class?(/some/, :test)).to be_true
    end

    it 'html_class? with Array' do
      element.html_class = [:a, :b, :c]
      expect(element.html_class?(%w(a d))).to be_true
      expect(element.html_class?(%w(e d))).to be_false
    end

    it 'html_class? with block' do
      element.html_class = [:a, :b, :c]
      expect(element.html_class? { |x| x == 'a' }).to be_true
    end
  end
end
