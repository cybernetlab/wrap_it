require 'spec_helper'

describe WrapIt::DerivedAttributes, type: :wrapped do
  describe '::get_derived' do
    it 'retrieves nil by default' do
      expect(wrapper_class.get_derived(:@var)).to be_nil
    end

    it 'retrieves var, defined in class' do
      wrapper_class.class_eval { @var = 1 }
      sub1 = Class.new(wrapper_class) { @var = 2 }
      sub2 = Class.new(sub1)
      expect(wrapper_class.get_derived(:@var)).to eq 1
      expect(sub1.get_derived(:@var)).to eq 2
      expect(sub2.get_derived(:@var)).to eq 2
    end
  end

  describe '::collect_derived' do
    it 'collects in array by default' do
      expect(wrapper_class.collect_derived(:@var)).to eq []
    end

    it 'collects vars in correct order' do
      wrapper_class.class_eval { @var = '1' }
      sub1 = Class.new(wrapper_class) { @var = '2' }
      sub2 = Class.new(sub1)
      expect(wrapper_class.collect_derived(:@var, [], :push)).to eq %w(1)
      expect(sub1.collect_derived(:@var, [], :push)).to eq %w(2 1)
      expect(sub2.collect_derived(:@var, [], :push)).to eq %w(2 1)
    end

    it 'collects arrays by default' do
      wrapper_class.class_eval { @var = %w(1 2) }
      sub1 = Class.new(wrapper_class) { @var = %w(2 3) }
      expect(wrapper_class.collect_derived(:@var)).to eq %w(1 2)
      expect(sub1.collect_derived(:@var)).to eq %w(2 3 1 2)
    end

    it 'collects hashes' do
      wrapper_class.class_eval { @var = { one: 1, two: 2 } }
      sub1 = Class.new(wrapper_class) { @var = { three: 3 } }
      expect(
        wrapper_class.collect_derived(:@var, {}, :merge)
      ).to eq(one: 1, two: 2)
      expect(
        sub1.collect_derived(:@var, {}, :merge)
      ).to eq(one: 1, two: 2, three: 3)
    end
  end
end
