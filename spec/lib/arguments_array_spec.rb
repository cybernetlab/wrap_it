require 'spec_helper'

describe WrapIt::CaptureArray do
  it 'avoid of include these module into non-array like class' do
    expect do
      Class.new(String) { include WrapIt::CaptureArray }
    end.to raise_error TypeError
  end

  context 'having test array' do
    let :array do
      arr = [10, :symbol, :another_symbol, 'string', 'another string']
      arr.extend described_class
    end

    it 'extracts by class name' do
      expect(array.capture!(Fixnum)).to eq [10]
      expect(array).to_not include 10
    end

    it 'captures by equality' do
      expect(array.capture!(:symbol, 'string')).to eq [:symbol, 'string']
      expect(array).to_not include :symbol, 'string'
    end

    it 'captures by regexp' do
      expect(
        array.capture!(/\Aanother/)
      ).to eq [:another_symbol, 'another string']
      expect(array).to_not include :another_symbol, 'another string'
    end

    it 'captures by array includance' do
      expect(array.capture!([10, :symbol])).to eq [10, :symbol]
      expect(array).to_not include 10, :symbol
    end

    it 'captures by block' do
      expect(array.capture! { |x| x == 10 }).to eq [10]
      expect(array).to_not include 10
    end

    it 'captures first by class name' do
      expect(array.capture_first!(Symbol)).to eq :symbol
      expect(array).to_not include :symbol
    end

    it 'captures first by equality' do
      expect(array.capture_first!(:symbol, 'string')).to eq :symbol
      expect(array).to_not include :symbol
    end

    it 'captures first by regexp' do
      expect(array.capture_first!(/\Aanother/)).to eq :another_symbol
      expect(array).to_not include :another_symbol
    end

    it 'captures first by array includance' do
      expect(array.capture_first!([10, :symbol])).to eq 10
      expect(array).to_not include 10
    end

    it 'captures first by block' do
      expect(array.capture_first! { |x| x.is_a?(Symbol) }).to eq :symbol
      expect(array).to_not include :symbol
    end

    it '#capture_first! returns nil if no matches' do
      expect(array.capture_first!(20)).to be_nil
      expect(array.size).to eq 5
    end

    it '#capture! returns [] if no matches' do
      expect(array.capture!(20)).to eq []
      expect(array.size).to eq 5
    end

    it 'works fine with met `and` conditions' do
      expect(array.capture!(Symbol, and: [:symbol])).to eq [:symbol]
      expect(array).to_not include :symbol
    end

    it 'works fine with unmet `and` conditions ' do
      expect(array.capture!(Symbol, and: [:sym])).to eq []
      expect(array).to include :symbol
    end

    it 'calls lambdas before comparison' do
      expect(array.capture!(-> {:symbol})).to eq [:symbol]
      expect(array).to_not include :symbol
    end
  end
end
