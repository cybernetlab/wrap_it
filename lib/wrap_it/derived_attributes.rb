module WrapIt
  #
  # Adds minimal support to retrieve derived class variables
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module DerivedAttributes
    def self.included(base)
      base.extend ClassMethods
    end

    #
    # Class methods to include
    #
    module ClassMethods
      def get_derived(name)
        return instance_variable_get(name) if instance_variable_defined?(name)
        ancestors.each do |ancestor|
          break if ancestor == Base
          next unless ancestor.instance_variable_defined?(name)
          return ancestor.instance_variable_get(name)
        end
        nil
      end

      def collect_derived(name, initial = [], method = :concat)
        result = initial
        ancestors.each do |ancestor|
          break if ancestor == Base
          next unless ancestor.instance_variable_defined?(name)
          result = result.send(method, ancestor.instance_variable_get(name))
        end
        result
      end
    end
  end
end
