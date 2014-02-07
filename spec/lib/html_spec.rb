require 'spec_helper'

describe WrapIt::HTML, type: :wrapped do
  it_behaves_like 'Base module'

  describe '#html_data' do
    it 'sets data as {} by default' do
      expect(wrapper.html_data).to be_kind_of(Hash)
    end
  end

  describe '#html_attr' do
    it 'sets attr as {} by default' do
      expect(wrapper.html_attr).to be_kind_of(Hash)
    end
  end

  describe '#html_class' do
    it 'sets class HTMLClass by default' do
      expect(wrapper.html_class).to be_kind_of(WrapIt::HTMLClass)
    end
  end

  it 'has self.html_class and #html_class methods' do
    wrapper_class.class_eval { html_class :a, [:b, 'c'] }
    expect(wrapper.html_class).to match_array %w(a b c)
    sub_class = Class.new(wrapper_class) { html_class :a, [:d, 'e'] }
    expect(sub_class.new(template_wrapper).html_class)
      .to match_array %w(a d e b c)
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
      expect(sub_class.new(template_wrapper).html_class_prefix).to eq 'e-'
    end
  end
end

describe WrapIt::HTMLClass do
  it 'has #<< with chaining' do
    expect(subject << :test).to match_array %w(test)
    subject.clear
    expect(subject << :a << 'b').to match_array %w(a b)
    subject.clear
    expect(subject << :a << [:b, :c]).to match_array %w(a b c)
  end

  it 'has #delete' do
    subject << :a << :b
    expect(subject.delete('a')).to match_array %w(b)
  end

  it 'has #include? method' do
    subject << [:a1, :b1]
    expect(subject.include?('a1')).to be_true
    expect(subject.include?(:a1, :b1)).to be_true
    expect(subject.include?(:a1, :b2)).to be_false
    expect(subject.include?(:a2)).to be_false
    expect(subject.include?(/\d+/)).to be_true
    expect(subject.include?(%w(a1 c1))).to be_true
    expect(subject.include? { |x| x[0] == 'a' }).to be_true
  end

=begin
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
=end
end
