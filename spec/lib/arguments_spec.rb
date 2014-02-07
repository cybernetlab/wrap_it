require 'spec_helper'

describe WrapIt::Arguments, type: :wrapped do
  # DSL
  %i(argument option).each do |m|
    describe ".#{m}" do
      let(:params) { wrapper_class.instance_variable_get("@#{m}s") }

      describe 'attribute parsing' do
        it "rejects non-string name" do
          expect { wrapper_class.send(m, 0) }.to raise_error ArgumentError
        end

        it 'symbolizes name' do
          wrapper_class.send(m, 'name')
          expect(params).to include :name
        end

        it 'makes conditions from name' do
          wrapper_class.send(m, :name)
          expect(params[:name][:conditions]).to eq [:name]
        end

        it 'wraps string-like conditions in array' do
          wrapper_class.send(m, :name, if: [:one, 'two'])
          expect(params[:name][:conditions]).to eq [[:one, 'two']]
        end

        it 'adds and option to conditions' do
          wrapper_class.send(m, :name, if: 0, and: 1)
          expect(params[:name][:conditions]).to eq [0, and: [1]]
        end

        it 'wraps string-like and in array' do
          wrapper_class.send(m, :name, if: 0, and: [:one, 'two'])
          expect(params[:name][:conditions]).to eq [0, and: [[:one, 'two']]]
        end
      end

      if m == :argument
        it 'permits :after_options' do
          wrapper_class.argument :name, after_options: true
          expect(params[:name][:after_options]).to be_true
        end
      end
    end
  end

  describe '.extract_for_class' do
    let(:args) { wrapper_class.send :provided_arguments }
    let(:opts) { wrapper_class.send :provided_options }

    it 'extracts arguments' do
      wrapper_class.argument :name
      a = [:name, :name, :test]
      wrapper_class.send(:extract_for_class, a, {})
      expect(args[:name]).to match_array [:name, :name]
      expect(a).to match_array [:test]
    end

    it 'extracts options' do
      wrapper_class.option :name
      o = {name: :opt}
      wrapper_class.send(:extract_for_class, [], o)
      expect(opts[:name]).to eq(name: :opt)
      expect(o).to be_empty
    end
  end

  before do
    wrapper_class.class_eval { attr_accessor :test }
  end
=begin
    it 'extracts arguments by conditions' do
      wrapper_class.class_eval do
        attr_accessor :i
        argument(:arg, if: Symbol) { |_| self.i = (i || 0) + 1 }
      end
      expect_any_instance_of(WrapIt::CaptureArray)
        .to receive(:capture!).with(Symbol).and_call_original
      expect(wrapper(:test, :multiple, :args).i).to eq 3
    end

    it 'extracts arguments to setters' do
      wrapper_class.class_eval { argument :test }
      expect(wrapper(:test).test).to be_true
    end
=end

#    it 'extracts only first arguments with first_only: true' do
#      wrapper_class.class_eval do
#        attr_accessor :i
#        argument(:arg, if: Symbol, first_only: true) do |_|
#          self.i = (i || 0) + 1
#        end
#      end
#      expect_any_instance_of(WrapIt::CaptureArray)
#        .to receive(:capture_first!).and_call_original
#      expect(wrapper(:test, :multiple, :args).i).to eq 1
#    end

=begin
  # class methods
  describe '.capture_arguments!' do
    it 'extracts argument' do
      wrapper_class.class_eval { argument :test }
      args = %i(test args)
      extracted = wrapper_class.capture_arguments!(args)
      expect(extracted).to match_array %i(test)
      expect(args).to match_array %i(args)
    end

    it 'extracts option' do
      wrapper_class.class_eval { option :test_option }
      args = [:test, :arg, test_option: 1]
      extracted = wrapper_class.capture_arguments!(args)
      expect(extracted).to match_array [test_option: 1]
      expect(args).to match_array [:test, :arg]
      args = [:test, :arg, test_option: 1, another: 0]
      extracted = wrapper_class.capture_arguments!(args)
      expect(extracted).to match_array [test_option: 1]
      expect(args).to match_array [:test, :arg, another: 0]
    end

    it 'calls arguments extarct! method' do
      wrapper_class.class_eval { argument :test }
      args = double(%i(test args))
      expect(args).to receive(:is_a?).with(Array).and_return(true)
      expect(args).to receive(:extract_options!).and_return({})
      expect(args).to receive(:extract!).with(:test).and_return([])
      wrapper_class.extract_arguments!(args)
    end
  end

  describe '#capture_arguments!' do
    it 'calls block for finded arguments in instance context' do
      wrapper_class.class_eval do
        argument(:test) { html_class << 'test' }
      end
      wrapper.send(:capture_arguments!, %i(test args))
      expect(wrapper.html_class).to include 'test'
    end

    it 'calls block for finded options in instance context' do
      wrapper_class.class_eval do
        option(:test_me) { html_class.push 'test' }
      end
      wrapper.send(:capture_arguments!, [test_me: :args])
      expect(wrapper.html_class).to include 'test'
    end
  end
=end
end
