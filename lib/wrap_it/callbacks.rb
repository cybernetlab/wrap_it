module WrapIt
  #
  # Callbacks implementation
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Callbacks
    extend DerivedAttributes

    def self.included(base)
      base.extend ClassMethods
    end

    def run_callbacks(name)
      self.class.collect_derived("@before_#{name}").each do |cb|
        if cb.is_a?(Symbol)
#          break if send(cb) == false # if respond_to?(cb)
          send(cb) # if respond_to?(cb)
        else
#          break if instance_eval(&cb) == false
          instance_eval(&cb)
        end
      end
      yield if block_given?
      self.class.collect_derived("@after_#{name}").reverse.each do |cb|
        if cb.is_a?(Symbol)
#          break if send(cb) == false # if respond_to?(cb)
          send(cb) # if respond_to?(cb)
        else
#          break if instance_eval(&cb) == false
          instance_eval(&cb)
        end
      end
    end

    #
    # Class methods to include
    #
    module ClassMethods
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
