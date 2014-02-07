module WrapIt
  #
  # Adds enums functionality
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Enums
    # Documentation includes
    # @!parse extend  Enums::ClassMethods

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

        before_initialize { @enums = {} }

        before_capture do
          self.class.collect_derived(:@enums, {}, :merge).each do |name, e|
            next unless e.key?(:default) && !@enums.key?(name)
            send("#{name}=", e[:default])
          end
        end
      end
    end

    #
    # {Enums} class methods
    #
    module ClassMethods
      #
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
      # @example
      #   class Button < WrapIt::Base
      #     enum :style, %i(red green black), html_class_prefix: 'btn-'
      #   end
      #
      #   btn = Button.new(template, :green)
      #   btn.render # => '<div class="btn-green">'
      #   btn = Button.new(template, style: :red)
      #   btn.render # => '<div class="btn-red">'
      #
      # @param  name [String, Symbol] Enum name. Converted to `Symbol`.
      # @param  opts [Hash] Enum options
      # @option opts [String, Symbol] :html_class_prefix prefix of HTML
      #   class that will automatically added to element if enum changes its
      #   value.
      # @option opts [Boolean] :html_class whether this enum changes
      #   should affect to html class.
      # @option opts [Symbol, Array<Symbol>] :aliases list of enum aliases.
      #   Warning! Values are not converted - pass only `Symbols` here.
      # @option opts [String, Symbol] :default default value for enum,
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
        define_method("#{name}") { @enums[name] ||= opts[:default] }
        define_method("#{name}=", &Enums.setter(name, &block))
        @enums ||= {}

        o_params = {}
        if opts.key?(:aliases)
          aliases = [opts[:aliases]].flatten.compact
          o_params[:if] = [name] + aliases
        end

        @enums[name] = opts
        option(name, **o_params) { |_, v| send("#{name}=", v) }
        argument(name, if: Symbol, and: values) { |_, v| send("#{name}=", v) }
      end
    end

    private

    def self.setter(name, &block)
      ->(value) do
        opts = self.class.collect_derived(:@enums, {}, :merge)[name]
        v = value if opts[:values].include?(value)
        v ||= opts[:default] if opts.key?(:default)
        @enums[name] = v
        block.nil? || instance_exec(v, &block)
        if opts.key?(:regexp)
          html_class.delete(opts[:regexp])
          v.nil? || html_class << "#{opts[:html_class_prefix]}#{v}"
        end
      end
    end
  end
end
