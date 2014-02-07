require 'spec_helper'

describe WrapIt::HTMLData do
  describe 'self.sanitize' do
    it { expect(described_class.sanitize).to eq ({}) }

    it 'stringifies values' do
      expect(described_class.sanitize(test: 1, subj: 2))
        .to eq(test: '1', subj: '2')
    end

    it 'splits dashed keys' do
      expect(described_class.sanitize(:'test-me-now' => 1, subj: 2))
        .to eq(test: {me: {now: '1'}}, subj: '2')
    end

    it 'parses nested hash' do
      expect(described_class.sanitize(test: {:'me-now' => 1}, subj: 2))
        .to eq(test: {me: {now: '1'}}, subj: '2')
    end

    it 'removes bogous symbols from keys' do
      expect(described_class.sanitize(test: {:'me_n%ow' => 1}, subj: 2))
        .to eq(test: {me_now: '1'}, subj: '2')
    end
  end
end
