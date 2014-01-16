module WrapIt
  #
  # Adds enums functionality
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Enums
    def self.included(base)
      base <= Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base subclasses"
      )
      extend DerivedAttributes
      base.extend ClassMethods
      base.after_initialize :enums_init
    end

    private

    def enums_init
      opt_keys = @options.keys
      self.class.collect_derived(:@enums, {}, :merge).each do |name, opts|
        value = nil
        names = [name] + [opts[:aliases] || []].flatten
        opt_keys.select { |o| names.include? o }.each do |key|
          tmp = @options.delete(key)
          value ||= tmp
          !value.nil? && !opts[:values].include?(value) && value = nil
        end
        @arguments.extract!(Symbol, and: [opts[:values]]).each do |key|
          value ||= key
        end
        send("#{name}=", value)
      end
    end

    #
    # Class methods to include
    #
    module ClassMethods
      #
      # @dsl
      # Adds `enum`. When element created, creation arguments will be scanned
      # for `Symbol`, that included contains in `values`. If it founded, enum
      # takes this value. Also creation options inspected. If its  contains
      # `name: value` key-value pair with valid value, this pair removed from
      # options and enum takes this value.
      #
      # This method also adds getter and setter for this enum.
      #
      # @param  name [String, Symbol] Enum name. Converted to `Symbol`.
      # @param  options = {} [Hash] Enum options
      # @options options [String, Symbol] :html_class_prefix prefix of HTML
      #   class that will automatically added to element if enum changes its
      #   value.
      # @options options [Symbol, Array<Symbol>] :aliases list of enum aliases.
      #   Warning! Values are not converted - pass only `Symbols` here.
      # @options options [String, Symbol] :default default value for enum,
      #   if nil or wrong value given. Converted to `Symbol`.
      # @yield [value] Runs block when enum value changed, gives it to block.
      # @yieldparam value [Symbol] New enum value.
      # @yieldreturn [void]
      #
      # @return [void]
      def enum(name, values, options = {}, &block)
        options.symbolize_keys!
        name = name.to_sym
        options.merge!(block: block, name: name, values: values)
        options.key?(:default) && options[:default] = options[:default].to_sym
        options.key?(:html_class_prefix) && options[:regexp] =
          /\A#{options[:html_class_prefix]}(?:#{values.join('|')})\z/
        var = "@#{name}".to_sym
        define_method("#{name}") { instance_variable_get(var) }
        define_method("#{name}=") do |value|
          v = value if values.include?(value)
          v ||= options[:default] if options.key?(:default)
          instance_variable_set(var, v)
          block.nil? || instance_exec(v, &block)
          if options.key?(:regexp)
            remove_html_class(options[:regexp])
            v.nil? || add_html_class("#{options[:html_class_prefix]}#{v}")
          end
        end
        @enums ||= {}
        @enums[name] = options
      end
    end
  end
end
