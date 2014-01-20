require 'spec_helper'

describe WrapIt do
  describe 'self.register_module' do
    it 'registers existing module' do
      mod = Module.new
      expect(WrapIt.register_module(mod)).to eq mod
    end

    it 'makes anonymous module if no module specified' do
      expect(WrapIt.register_module).to be_kind_of Module
    end

    %i(register unregister).each do |method|
      it "adds `#{method}` method to module" do
        expect(WrapIt.register_module).to respond_to method
      end
    end

    it 'supports prefix for helpers' do
      mod = WrapIt.register_module prefix: 'test_'
      mod.register :method, Object
      expect(mod.instance_methods).to include :test_method
    end
  end
end
