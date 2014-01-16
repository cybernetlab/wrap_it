require 'spec_helper'

describe WrapIt::Base do
  it 'have #tag getter' do
    expect(successor.tag).to eq 'div'
  end

  it 'have default_tag class method' do
    successor_class.class_eval { default_tag 'a' }
    expect(successor.tag).to eq 'a'
  end

  it 'extends @arguments with ArgumentsArray module' do
    expect(
      successor.instance_variable_get(:@arguments)
    ).to be_kind_of WrapIt::ArgumentsArray
  end

  it 'symbolizes options hash' do
    successor.send :options=, 'my' => 'value'
    expect(successor.options).to eq(my: 'value', class: [])
  end

  it 'sanitizes options class' do
    successor.send :options=, class: [:one, :two, :two]
    expect(successor.options[:class]).to eq %w(one two)
  end

  it 'calls after_initialize' do
    successor_class.class_eval { after_initialize { add_html_class :a } }
    expect(successor.html_class).to eq %w(a)
  end

  it 'not omits content by default' do
    expect(successor.omit_content?).to be_false
  end

  it 'provides way to omit content in subclasses' do
    successor_class.class_eval { omit_content }
    expect(successor.omit_content?).to be_true
  end

  it 'removes `helper_name` from options' do
    successor(helper_name: 'test')
    expect(successor.options).to_not include :helper_name
    expect(successor.instance_variable_get(:@helper_name)).to eq :test
  end
end
