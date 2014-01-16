require 'spec_helper'

describe WrapIt::Switches do
  context 'wrapper have `active` switch' do
    before { wrapper_class.class_eval { switch :active } }

    it 'adds getters' do
      expect(wrapper.active?).to be_false
      wrapper.active = true
      expect(wrapper.active?).to be_true
    end

    it 'gets switch from arguments' do
      expect(wrapper(:active).active?).to be_true
    end

    it 'string arguments are ignored' do
      expect(wrapper('active').active?).to be_false
    end

    it 'gets switch from options' do
      expect(wrapper(active: true).active?).to be_true
      @wrapper = nil
      expect(wrapper(active: false).active?).to be_false
      expect(wrapper.options).to_not include :active
    end

    it 'runs block' do
      wrapper_class.class_eval do
        switch(:active) { |x| add_html_class(x.to_s) }
      end
      expect(wrapper(:active).html_class).to include 'true'
      @wrapper = nil
      expect(wrapper(active: true).html_class).to include 'true'
      @wrapper = nil
      expect(wrapper(active: false).html_class).to include 'false'
      wrapper.active = true
      expect(wrapper.html_class).to include 'true'
      wrapper.active = false
      expect(wrapper.html_class).to include 'false'
    end

    it 'adds and removes html class' do
      wrapper_class.class_eval { switch :active, html_class: 'active' }
      expect(wrapper(:active).html_class).to include 'active'
      @wrapper = nil
      expect(wrapper(active: true).html_class).to include 'active'
      @wrapper = nil
      expect(wrapper(active: false).html_class).to_not include 'active'
      wrapper.active = true
      expect(wrapper.html_class).to include 'active'
      wrapper.active = false
      expect(wrapper.html_class).to_not include 'active'
    end

    it 'detects aliases' do
      wrapper_class.class_eval { switch :active, aliases: :act }
      expect(wrapper(:act).active?).to be_true
      @wrapper = nil
      expect(wrapper(act: true).active?).to be_true
      @wrapper = nil
      expect(wrapper(act: false).active?).to be_false
      expect(wrapper).to_not respond_to :act?
    end
  end
end
