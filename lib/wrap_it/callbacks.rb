module WrapIt
  #
  # Callbacks implementation
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Callbacks
    # Documentation includes
    # @!parse extend  Callbacks::ClassMethods

    # module implementation

    extend DerivedAttributes

    #
    def self.included(base)
      base.extend ClassMethods
    end

    #
    # Runs specified callbacks with block
    #
    # Runs first `before` callbacks in inheritance order, then yields block if
    # it given and then `after` callbacks in reverse order.
    #
    # @param  name [Symbol] callback name, that should be defined by
    #   {ClassMethods#callback callback} method.
    #
    # @return [void]
    def run_callbacks(name)
      self.class.collect_derived("@before_#{name}").each do |cb|
        if cb.is_a?(Symbol)
          send(cb) # if respond_to?(cb)
        else
          instance_eval(&cb)
        end
      end
      yield if block_given?
      self.class.collect_derived("@after_#{name}").reverse.each do |cb|
        if cb.is_a?(Symbol)
          send(cb) # if respond_to?(cb)
        else
          instance_eval(&cb)
        end
      end
    end

    #
    # {Callbacks} class methods
    #
    module ClassMethods
      #
      # Defines callback
      #
      # @overload callback([name, ...])
      #   @param  name [Symbol, String] callback name
      #
      # @return [void]
      def callback(*args)
        args.each do |name|
          instance_eval(&Callbacks.define_callback(:before, name))
          instance_eval(&Callbacks.define_callback(:after, name))
        end
      end
    end

    private

    def self.define_callback(time, name)
      m_name = "#{time}_#{name}".to_sym
      var = "@#{m_name}".to_sym
      proc do
        define_singleton_method(m_name) do |method = nil, &block|
          return if block.nil? && !method.is_a?(Symbol)
          arr =
            if instance_variable_defined?(var)
              instance_variable_get(var)
            else
              instance_variable_set(var, [])
            end
          action = self == ancestors.first ? :unshift : :push
          arr.send(action, block || method)
          instance_variable_set(var, arr)
        end
      end
    end
  end
end
