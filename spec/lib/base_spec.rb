require 'spec_helper'

describe WrapIt::Base, type: :wrapped do
  it 'have #tag getter' do
    expect(successor.tag).to eq 'div'
  end

  it 'have default_tag class method' do
    successor_class.class_eval { default_tag 'a' }
    expect(successor.tag).to eq 'a'
  end

  it 'gets tag name from options' do
    expect(successor(tag: 'p').tag).to eq 'p'
  end

  it 'calls after_initialize' do
    successor_class.class_eval { after_initialize { html_class << :a } }
    expect(successor.html_class).to eq %w(a)
  end

  it 'not omits content by default' do
    expect(successor.omit_content?).to be_false
  end

  it 'provides way to omit content in subclasses' do
    successor_class.class_eval { omit_content }
    expect(successor.omit_content?).to be_true
  end
end
