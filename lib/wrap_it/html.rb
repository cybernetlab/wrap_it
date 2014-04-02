require File.join %w(wrap_it html_class)
require File.join %w(wrap_it html_data)

module WrapIt
  #
  # Methods for manipulationg with HTML class. For internal usage.
  # You should not include this class directly - subclass from
  # `WrapIt::Base` instead.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module HTML
    # Documentation includes
    # @!parse extend  HTML::ClassMethods

    # module implementation

    extend DerivedAttributes

    #
    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
      base.class_eval do
        extend ClassMethods

        option(:class) { |_, v| self.html_class << v }

        # TODO: extend hashes for html_attr and html_data
        before_initialize do
          html_class
          @html_attr ||= {}
          @html_data ||= {}
        end
      end
    end

    # TODO: actually we should have separate setter and merge (see Base)
    #
    # Sets HTML attributes hash.
    #
    # Actually it merges its with current
    # attributes. To remove some attributes use `html_attr.delete(:attr)`.
    # extracts HTML class and data from provided hash and places its to
    # appropriate holder
    #
    # @param  hash [Hash] attributes
    #
    # @return [Hash] resulting attributes
    def html_attr=(hash)
      return unless hash.is_a?(Hash)
      hash.symbolize_keys!
      html_class << hash.delete(:class)
      html_data.merge(hash.delete(:data) || {})
      (@html_attr ||= {}).merge!(hash)
    end

    #
    # Retrieves HTML attributes hash (without HTML class and HTML data)
    #
    # @return [Hash] attributes
    def html_attr
      @html_attr ||= {}
    end

    #
    # Retrieves HTML data hash
    #
    # @return [Hash] data
    def html_data
      @html_data ||= {}
    end

    #
    # HTML class prefix getter
    #
    # This prefix used in enums to combine HTML classes.
    #
    # @return [String] HTML class prefix.
    def html_class_prefix
      @html_class_prefix ||= self.class.html_class_prefix
    end

    #
    # Sets HTML class(es) for element
    #
    # @example
    #   element.html_class = [:a, 'b', ['c', :d, 'a']]
    #   element.html_class #=> ['a', 'b', 'c', 'd']
    #
    # @param  value [Symbol, String, Array<Symbol, String>] HTML class or list
    #   of classes. All classes will be converted to Strings, duplicates are
    #   removed. Refer to {HTMLClass} description for details.
    # @return [HTMLClass] resulting html class
    def html_class=(value)
      @html_class = HTMLClass.new(value)
    end

    #
    # Retrieves HTML class of element
    #
    # See {HTMLClass} for details
    #
    # @return [HTMLClass] HTML class of element
    def html_class
      @html_class ||= HTMLClass.new
    end

    protected

    def add_default_classes
      html_class << self.class.collect_derived(
        :@html_class, HTMLClass.new, :<<
      )
    end

    #
    # {HTML} class methods
    #
    module ClassMethods
      using EnsureIt if ENSURE_IT_REFINED

      #
      # Adds default html classes, thats are automatically added when element
      # created.
      # @overload html_class([html_class, ...])
      #   @param  html_class [String, Symbol, Array<String, Symbol>] HTML class.
      #     Converted to `String`
      #
      # @return [void]
      def html_class(*args)
        (@html_class ||= HTMLClass.new) << args
      end

      #
      # Sets HTML class prefix. It used in switchers and enums
      # @param  prefix [String] HTML class prefix
      #
      # @return [void]
      def html_class_prefix(prefix = nil)
        return(get_derived(:@html_class_prefix) || '') if prefix.nil?
        @html_class_prefix = prefix.ensure_string!
      end
    end
  end
end
