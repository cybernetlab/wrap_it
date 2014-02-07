require 'spec_helper'

describe WrapIt::TextContainer, type: :wrapped do
  it { expect(wrapper_class.default_tag).to eq 'p' }

  %i(text body).each do |option|
    it "gets text from `#{option}` option" do
      expect(wrapper(option => 'text').body).to eq 'text'
    end

    it "cleanups `#{option}` for options" do
      expect(wrapper(option => 'text').html_attr).to_not include option
    end
  end

  it 'gets text from first String argument' do
    expect(wrapper(:symbol, 'text', 'other').body).to eq 'text'
  end
end
