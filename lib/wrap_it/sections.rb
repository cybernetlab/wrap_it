module WrapIt
  #
  # Adds sections functionality
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Sections
    extend DerivedAttributes

    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
      base.extend ClassMethods
    end

    def [](name)
      @section_names ||= self.class.sections
      return nil unless @section_names.include?(name)
      @sections ||= {}
      @sections[name] ||= empty_html
    end

    def []=(name, value)
      @section_names ||= self.class.sections
      return unless @section_names.include?(name)
      @sections ||= {}
      @sections[name] = value
    end

    #
    # Class methods to include
    #
    module ClassMethods
      def sections
        collect_derived(:@sections)
      end

      def section(*args)
        @sections ||= []
        args.flatten.each do |name|
          name.is_a?(String) && name = name.to_sym
          next unless name.is_a?(Symbol)
          next if (sections + [:begin, :end]).include?(name)
          @sections << name
          placement << name unless placement.include?(name)
          place name, before: :end
        end
      end

      def placement
        @placement ||=
          if self == Base
            sections.clone
          else
            parent = ancestors[1..-1].find { |a| a.respond_to?(:placement) }
            parent.nil? ? sections.clone : parent.placement.clone
          end
      end

      def place(src, at, dst = nil)
        if dst == nil && at.is_a?(Hash) && at.keys.size == 1
          dst = at.values[0]
          at = at.keys[0]
        end
        return unless placement.include?(src) &&
          (dst == :begin || dst == :end || placement.include?(dst)) &&
          (at == :before || at == :after)
        item = placement.delete_at(placement.index(src))
        case dst
        when :begin then placement.unshift(item)
        when :end then placement.push(item)
        else
          x = at == :before ? 0 : 1
          placement.insert(placement.index(dst) + x, item)
        end
      end
    end
  end
end
