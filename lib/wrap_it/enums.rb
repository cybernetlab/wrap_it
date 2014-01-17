module WrapIt
  #
  # Adds enums functionality
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Enums
    extend DerivedAttributes

    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
      base.extend ClassMethods
      base.after_initialize :enums_init
    end

    private

    def enums_init
      opt_keys = @options.keys
      enums.each do |name, opts|
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

    def enums
      @nums ||= self.class.collect_derived(:@enums, {}, :merge)
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
      # If you set `html_class` option to `true`, with each enum change, HTML
      # class, composed from `html_class_prefix` and enum `value` will be
      # added to element. If you want to override this prefix, specify it
      # with `html_class_prefix` option. By default, enum changes are not
      # affected to html classes.
      #
      # This method also adds getter and setter for this enum.
      #
      # @param  name [String, Symbol] Enum name. Converted to `Symbol`.
      # @param  options = {} [Hash] Enum options
      # @options options [String, Symbol] :html_class_prefix prefix of HTML
      #   class that will automatically added to element if enum changes its
      #   value.
      # @options options [Boolean] :html_class whether this enum changes
      #   should affect to html class.
      # @options options [Symbol, Array<Symbol>] :aliases list of enum aliases.
      #   Warning! Values are not converted - pass only `Symbols` here.
      # @options options [String, Symbol] :default default value for enum,
      #   if nil or wrong value given. Converted to `Symbol`.
      # @yield [value] Runs block when enum value changed, gives it to block.
      # @yieldparam value [Symbol] New enum value.
      # @yieldreturn [void]
      #
      # @return [void]
      def enum(name, values, opts = {}, &block)
        opts.symbolize_keys!
        name = name.to_sym
        opts.merge!(block: block, name: name, values: values)
        opts.key?(:default) && opts[:default] = opts[:default].to_sym
        if opts.delete(:html_class) == true || opts.key?(:html_class_prefix)
          opts[:html_class_prefix].is_a?(Symbol) &&
            opts[:html_class_prefix] = opts[:html_class_prefix].to_s
          prefix = html_class_prefix
          opts[:html_class_prefix].is_a?(String) &&
            prefix = opts[:html_class_prefix]
          opts[:regexp] = /\A#{prefix}(?:#{values.join('|')})\z/
          opts[:html_class_prefix] = prefix
        end
        var = "@#{name}".to_sym
        define_method("#{name}") { instance_variable_get(var) }
        define_method("#{name}=", &Enums.setter(name, &block))
        @enums ||= {}
        @enums[name] = opts
      end
    end

    private

    def self.setter(name, &block)
      proc do |value|
        opts = enums[name]
        v = value if opts[:values].include?(value)
        v ||= opts[:default] if opts.key?(:default)
        instance_variable_set("@#{name}", v)
        block.nil? || instance_exec(v, &block)
        if opts.key?(:regexp)
          remove_html_class(opts[:regexp])
          v.nil? || add_html_class("#{opts[:html_class_prefix]}#{v}")
        end
      end
    end
  end
end
