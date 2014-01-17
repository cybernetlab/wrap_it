require 'spec_helper'

describe WrapIt::HTMLData do
  it_behaves_like 'Base module'

  describe '#set_html_data' do
    it 'sets data' do
      wrapper.set_html_data(:one, 'test')
      expect(wrapper.options[:data]).to eq(one: 'test')
    end
  end

  describe '#remove_html_data' do
    it 'removes data' do
      wrapper.set_html_data(:one, 'test')
      wrapper.remove_html_data(:one)
      expect(wrapper.options[:data]).to be_empty
    end
  end
end

