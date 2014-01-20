module WrapIt
  #
  # Adds switches functionality
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Switches
    extend DerivedAttributes

    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
      base.extend ClassMethods
      base.after_initialize :switches_init
    end

    private

    def switches_init
      @switches = {}
      keys = switches.keys
      @options.keys.select { |o| keys.include?(o) }.each do |switch|
        send("#{switches[switch][:name]}=", @options.delete(switch) == true)
      end
      @arguments.extract!(Symbol, and: [keys]).each do |switch|
        send("#{switches[switch][:name]}=", true)
      end
    end

    def switches
      @switches_hash ||= self.class.collect_derived(:@switches, {}, :merge)
    end

    #
    # Class methods to include
    #
    module ClassMethods
      #
      # @dsl
      # Adds `switch`. Switch is a boolean flag. When element created, creation
      # arguments will be scanned for `Symbol`, that equals to `name`. If
      # it founded, switch turned on. Also creation options inspected. If
      # its contains `name: true` key-value pair, this pair removed from
      # options and switch also turned on.
      #
      # This method also adds getter and setter for this switch in form `name?`
      # and `name=` respectively.
      #
      # When `html_class` option specified and switch changes its state, HTML
      # class for element will be computed as follows. if `html_class` options
      # is `true`, html class produced from `html_class_prefix` and `name` of
      # switch. If `html_class` is a String, Symbol or Array of this types,
      # html class produced as array of `html_class_prefix` and each
      # `html_class` concatinations. This classes added to element if switch is
      # on or removed in other case.
      #
      # @param  name [String, Symbol] Switch name. Converted to `Symbol`.
      # @param  opts [Hash] Switch options
      # @options opts [true, String, Symbol, Array<String, Symbol>] :html_class
      #   HTML classes list that will automatically added to element if switch
      #   is on or removed from element if switch id off.
      # @options opts [Symbol, Array<Symbol>] :aliases list of aliases.
      #   Warning! Values are not converted - pass only `Symbols` here.
      # @yield [state] Runs block when switch state changed, gives it to block.
      # @yieldparam state [Boolean] Whether switch is on or off.
      # @yieldreturn [Object, FalseClass] if you return `false`, value will
      #   ommited.
      #
      # @return [void]
      def switch(name, options = {}, &block)
        options.symbolize_keys!
        name = name.to_sym
        options.merge!(block: block, name: name)
        if options.key?(:html_class)
          options[:html_class] =
            if options[:html_class] == true
              [html_class_prefix + name.to_s]
            else
              HTMLClass.sanitize(options[:html_class]).map do |c|
                html_class_prefix + c
              end
            end
        end
        names = [name] + [[options[:aliases]] || []].flatten.compact
        define_method("#{name}?") { @switches[name] == true }
        define_method("#{name}=", &Switches.setter(name, &block))
        @switches ||= {}
        names.each { |n| @switches[n] = options }
      end
    end

    private

    #
    # Makes switch setter block
    # @param  name [String] switch name
    # @param  &block [Proc] switch block
    #
    # @return [Proc] switch setter block
    def self.setter(name, &block)
      proc do |value|
        opts = switches[name]
        cb_return = block.nil? || instance_exec(value == true, &block)
        unless cb_return == false
          @switches[name] = value == true
          if value == true
            opts.key?(:html_class) && add_html_class(*opts[:html_class])
          else
            opts.key?(:html_class) && remove_html_class(*opts[:html_class])
          end
        end
      end
    end
  end
end
