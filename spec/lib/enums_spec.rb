require 'spec_helper'

describe WrapIt::Enums do
  it_behaves_like 'Base module'

  context 'wrapper have `kind` enum' do
    before { wrapper_class.class_eval { enum :kind, [:white, :black] } }

    it 'adds getters' do
      expect(wrapper.kind).to be_nil
      wrapper.kind = true
      expect(wrapper.kind).to be_nil
      wrapper.kind = :white
      expect(wrapper.kind).to eq :white
    end

    it 'gets enum value from arguments' do
      expect(wrapper(:white).kind).to eq :white
    end

    it 'string arguments are ignored' do
      expect(wrapper('white').kind).to be_nil
    end

    it 'gets enum from options' do
      expect(wrapper(kind: :black).kind).to eq :black
      @wrapper = nil
      expect(wrapper(kind: false).kind).to be_nil
      expect(wrapper.options).to_not include :kind
    end

    it 'runs block' do
      wrapper_class.class_eval do
        enum(:kind, [:white, :black]) { |x| self.html_class = x.to_s }
      end
      expect(wrapper(:white).html_class).to include 'white'
      @wrapper = nil
      expect(wrapper(kind: :black).html_class).to include 'black'
      wrapper.kind = :white
      expect(wrapper.html_class).to include 'white'
    end

    it 'adds and removes html class' do
      wrapper_class.class_eval do
        enum :kind, [:white, :black], html_class_prefix: 'test-'
      end
      expect(wrapper(:white).html_class).to include 'test-white'
      @wrapper = nil
      expect(wrapper(kind: :black).html_class).to include 'test-black'
      @wrapper = nil
      expect(wrapper(kind: :no).html_class).to be_empty
      wrapper.kind = :white
      expect(wrapper.html_class).to include 'test-white'
      wrapper.kind = :black
      expect(wrapper.html_class).to include 'test-black'
      expect(wrapper.html_class).to_not include 'test-white'
    end

    it 'adds and removes html class with default html_class_prefix' do
      wrapper_class.class_eval do
        html_class_prefix 'test-'
        enum :kind, [:white, :black], html_class: true
      end
      expect(wrapper(:white).html_class).to include 'test-white'
    end

    it 'detects aliases' do
      wrapper_class.class_eval do
        enum :kind, [:white, :black], aliases: [:appearence]
      end
      expect(wrapper(appearence: :white).kind).to eq :white
    end

    it 'supports default values' do
      wrapper_class.class_eval do
        enum :kind, [:white, :black], default: :white
      end
      expect(wrapper.kind).to eq :white
      wrapper.kind = :black
      expect(wrapper.kind).to eq :black
      wrapper.kind = nil
      expect(wrapper.kind).to eq :white
      @wrapper = nil
      expect(wrapper(kind: :no).kind).to eq :white
      @wrapper = nil
      expect(wrapper(:black, kind: :no).kind).to eq :black
    end
  end
end
