module WrapIt
  #
  # Sections is a smart way to make complex components with inheritance.
  #
  # Sections is just array of named HTML markup pieces. You can place any
  # section before or after another at class level and change their content
  # at instance level.
  #
  # Each component have three stages. First is initialization, then sections
  # capturing and rendering. You can change any sections content until
  # rendering stage begins. Finally, renderer joins all sections in order,
  # that they have at render time.
  #
  # {WrapIt::Base} provides following sections: main section is `:content`.
  # All text from block captured there. `:render_arguments` and `:render_block`
  # also provided, so arguments and block passed to render method captured
  # here.
  #
  # Access to sections at instance level performed throw hash-like getter and
  # setter ([] and []=) of self.
  #
  # With this functionality you can easy organize you inheritance, so any
  # descendant can change sections order or any section content without
  # changes to unrelated sections.
  #
  # @example sections usage
  #   class IconedButton < WrapIt::Base
  #     include TextContainer
  #     html_class 'btn'
  #     section :icon
  #     place :icon, before: :content
  #
  #     after_capture do
  #       self[:icon] = html_safe('<i class="my-icon"></i>')
  #     end
  #   end
  #
  #   class RightIconedButton < IconedButton
  #     place :icon, after: :content
  #   end
  #
  #   b1 = IconedButton.new(template, 'text')
  #   b2 = RightIconedButton.new(template, 'text')
  #   b1.render # => '<div class="btn"><i class="my-icon"></i>text</div>'
  #   b2.render # => '<div class="btn">text<i class="my-icon"></i></div>'
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Sections
    # Documentation includes
    # @!parse extend  Sections::ClassMethods

    # module implementation

    extend DerivedAttributes

    #
    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
      base.extend ClassMethods
    end

    #
    # Retrieves specified section content
    # @param  name [Symbol] section name
    #
    # @return [String] section content
    def [](name)
      @section_names ||= self.class.sections
      return nil unless @section_names.include?(name)
      @sections ||= {}
      @sections[name] ||= empty_html
    end

    #
    # Sets specified section content
    # @param  name [Symbol] section name
    # @param  value [String] content
    #
    # @return [String] section content
    def []=(name, value)
      @section_names ||= self.class.sections
      return unless @section_names.include?(name)
      @sections ||= {}
      @sections[name] = value
    end

    #
    # {Sections} class methods
    #
    module ClassMethods
      #
      # Retrieves all sections, including ancestors
      #
      # @return [Array<Symbol>] array of sections
      def sections
        collect_derived(:@sections)
      end

      #
      # Defines new section or sections. Places its to end of section list
      #
      # @overload section([name, ...])
      #   @param name [Symbol, String] section name
      #
      # @return [void]
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

      #
      # Retrieves section names in current order
      #
      # @return [Array<Symbol>] ordered sections array
      def placement
        @placement ||=
          if self == Base
            sections.clone
          else
            parent = ancestors[1..-1].find { |a| a.respond_to?(:placement) }
            parent.nil? ? sections.clone : parent.placement.clone
          end
      end

      #
      # Places specific section in specified place
      #
      # @overload place(src, to)
      #   @param  src [Symbol] section name to place
      #   @param  to [Hash] single key-value hash. Key can be `:before` or
      #     `after`, value can be `:begin`, `:end` or section name
      #
      # @overload place(src, at, dst)
      #   @param  src [Symbol] section name to place
      #   @param  at [Symbol] can be `:before` or `:after`
      #   @param  dst [Symbol] can be `:begin`, `:end` or section name
      #
      # @return [void]
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
