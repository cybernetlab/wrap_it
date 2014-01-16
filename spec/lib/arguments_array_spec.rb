require 'spec_helper'

describe WrapIt::ArgumentsArray do
  it 'avoid of include these module into non-array like class' do
    expect do
      Class.new(String) { include WrapIt::ArgumentsArray }
    end.to raise_error TypeError
  end

  context 'having test array' do
    let :array do
      arr = [10, :symbol, :another_symbol, 'string', 'another string']
      arr.extend described_class
    end

    it 'extracts by class name' do
      expect(array.extract!(Fixnum)).to eq [10]
      expect(array).to_not include 10
    end

    it 'extracts by equality' do
      expect(array.extract!(:symbol, 'string')).to eq [:symbol, 'string']
      expect(array).to_not include :symbol, 'string'
    end

    it 'extracts by regexp' do
      expect(
        array.extract!(/\Aanother/)
      ).to eq [:another_symbol, 'another string']
      expect(array).to_not include :another_symbol, 'another string'
    end

    it 'extracts by array includance' do
      expect(array.extract!([10, :symbol])).to eq [10, :symbol]
      expect(array).to_not include 10, :symbol
    end

    it 'extracts by block' do
      expect(array.extract! { |x| x == 10 }).to eq [10]
      expect(array).to_not include 10
    end

    it 'extracts first by class name' do
      expect(array.extract_first!(Symbol)).to eq :symbol
      expect(array).to_not include :symbol
    end

    it 'extracts first by equality' do
      expect(array.extract_first!(:symbol, 'string')).to eq :symbol
      expect(array).to_not include :symbol
    end

    it 'extracts first by regexp' do
      expect(array.extract_first!(/\Aanother/)).to eq :another_symbol
      expect(array).to_not include :another_symbol
    end

    it 'extracts first by array includance' do
      expect(array.extract_first!([10, :symbol])).to eq 10
      expect(array).to_not include 10
    end

    it 'extracts first by block' do
      expect(array.extract_first! { |x| x.is_a?(Symbol) }).to eq :symbol
      expect(array).to_not include :symbol
    end

    it '#extract_first! returns nil if no matches' do
      expect(array.extract_first!(20)).to be_nil
      expect(array.size).to eq 5
    end

    it '#extract! returns [] if no matches' do
      expect(array.extract!(20)).to eq []
      expect(array.size).to eq 5
    end

    it 'works with and conditions' do
      expect(array.extract!(Symbol, and: [:symbol])).to eq [:symbol]
      expect(array).to_not include :symbol
    end
  end
end
