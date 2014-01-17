require 'spec_helper'

describe WrapIt::Link do
  it 'has `a` tag by default' do
    expect(successor.tag).to eq 'a'
  end

  it { expect(successor).to be_kind_of WrapIt::TextContainer }

  it 'takes href from options' do
    [:link, :href, :url].each do |key|
      @successor = nil
      expect(successor(key => 'url').href).to eq 'url'
    end
  end

  it 'takes href from first string arg if block present' do
    expect(successor('url') { 'text' }.href).to eq 'url'
  end

  it 'takes href from second string arg if no block given' do
    expect(successor('text', 'url').href).to eq 'url'
    expect(successor.instance_variable_get(:@body)).to eq 'text'
  end
end
