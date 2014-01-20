module WrapIt
  module ModuleHelpers
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def placement(name)
        define_method(
          "#{name}_placement", &ModuleHelpers.placement_block(name)
        )
      end
    end

    private

    def placement_block(name)
      proc do |hash = {before: :content}|

      end
    end
  end
end
