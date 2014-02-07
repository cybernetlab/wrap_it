module WrapIt
  #
  # Adds minimal support to retrieve derived class variables
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module DerivedAttributes
    # Documentation includes
    # @!parse extend  DerivedAttributes::ClassMethods

    # module implementation

    #
    def self.included(base)
      base.extend ClassMethods
    end

    #
    # {DerivedAttributes} class methods
    #
    module ClassMethods
      #
      # retrieves first founded derived variable or nil
      # @param  name [Symbol] variable name (should contain `@` sign)
      #
      # @return [Object, nil] founded variable or nil
      def get_derived(name)
        return instance_variable_get(name) if instance_variable_defined?(name)
        ancestors.each do |ancestor|
          next unless ancestor.instance_variable_defined?(name)
          break if ancestor == Base
          return ancestor.instance_variable_get(name)
        end
        nil
      end

      #
      # Collects all derived variables with specified name
      # @param  name [Symbol] variable name (should contain `@` sign)
      # @param  initial [Object] initial collection object
      # @param  method [Symbol] collection's method name to concatinate
      #   founded variable with collection
      #
      # @return [Object] collection of variables
      def collect_derived(name, initial = [], method = :concat)
        result = initial
        ancestors.each do |ancestor|
          next unless ancestor.instance_variable_defined?(name)
          result = result.send(method, ancestor.instance_variable_get(name))
          break if ancestor == Base
        end
        result
      end
    end
  end
end
