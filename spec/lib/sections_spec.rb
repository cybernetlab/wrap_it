require 'spec_helper'

describe WrapIt::Sections do
  it_behaves_like 'Base module'

  describe 'self.section' do
    it 'adds sections' do
      wrapper_class.send(:section, :test, :section)
      expect(wrapper_class.sections).to include :test, :section
    end

    it 'drops duplicated sections' do
      wrapper_class.send(:section, :test, :section, :test)
      expect(wrapper_class.sections.size).to eq WrapIt::Base.sections.size + 2
    end

    it 'drops :begin and :end sections' do
      wrapper_class.send(:section, :begin, :end)
      expect(wrapper_class.sections.size).to eq WrapIt::Base.sections.size
    end

    it 'adds section to the end of placement' do
      wrapper_class.section(:test)
      expect(wrapper_class.placement.last).to eq :test
    end
  end

  describe 'self.sections' do
    it 'combines sections with derived' do
      wrapper_class.send(:section, :test)
      expect(wrapper_class.sections)
        .to match_array(WrapIt::Base.sections + [:test])
    end
  end

  describe 'self.placement' do
    it 'sets places as parent placement + @sections for Base subclasses' do
      wrapper_class.section(:test)
      wrapper_class.place(:test, after: wrapper_class.placement.first)
      expect(Class.new(wrapper_class).placement).to eq wrapper_class.placement
    end

    it 'clones sections' do
      wrapper_class.placement
      wrapper_class.instance_variable_get(:@placement).pop
      expect(wrapper_class.placement.size)
        .to eq wrapper_class.sections.size - 1
    end
  end

  describe 'self.place' do
    it 'places items right' do
      wrapper_class.section(:test)
      wrapper_class.place(:test, after: :begin)
      expect(wrapper_class.placement.first).to eq :test
      wrapper_class.place(:test, before: :end)
      expect(wrapper_class.placement.last).to eq :test
      first = wrapper_class.placement.first
      wrapper_class.place(:test, after: first)
      expect(wrapper_class.placement[1]).to eq :test
      wrapper_class.place(:test, before: first)
      expect(wrapper_class.placement.first).to eq :test
    end
  end

  it 'adds hash-like access' do
    wrapper_class.section(:test)
    expect(wrapper[:test]).to eq ''
    wrapper[:test] << 'test'
    expect(wrapper[:test]).to eq 'test'
  end
end
