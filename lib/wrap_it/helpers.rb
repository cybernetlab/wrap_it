#
# Helper registering
#
# @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
#
module WrapIt
  def self.register_module(*args)
    options = args.extract_options!
    options.symbolize_keys!
    options = {prefix: ''}.merge(options)
    mod = args.shift
    mod.is_a?(Module) || mod = Module.new
    mod.instance_eval do
      define_singleton_method(:register, &WrapIt.register_block(options))
      define_singleton_method(:unregister, &WrapIt.unregister_block(options))
    end
    mod
  end

  private

  def self.register_block(options)
    # Runs in helpers module class context
    proc do |*args|
      class_name = args.pop
      class_name.is_a?(String) || class_name.is_a?(Class) || fail(
        ArgumentError,
        "Last argument for #{name}.register_helper should be a class name"
      )
      class_name.is_a?(Class) && class_name = class_name.name
      helpers = instance_methods
      args.each do |helper|
        !helper.is_a?(Symbol) && fail(
          ArgumentError,
          "First arguments for WrapIt.register" \
          " should be Symbols with helper names"
        )
        helpers.include?(helper) && fail(
          ArgumentError, "Helper #{helper} for WrapIt.register allready exists"
        )
        define_method(
          "#{options[:prefix]}#{helper}",
          WrapIt.method_block(helper, class_name)
        )
      end
    end
  end

  def self.unregister_block(options)
    # Runs in helpers module class context
    proc do |*list|
      helpers = instance_methods
      list.each do |helper|
        helper.is_a?(String) && helper = helper.to_sym
        next unless helper.is_a?(Symbol)
        helper_name = "#{options[:prefix]}#{helper}"
        next unless helpers.include?(helper_name)
        remove_method helper_name
      end
    end
  end

  def self.method_block(name, class_name)
    # Runs in helpers module context
    proc do |*args, &block|
      opts = args.extract_options!
      opts[:helper_name] = name
      args << opts
      obj = Object.const_get(class_name).new(self, *args, &block)
      obj.render
    end
  end
end

