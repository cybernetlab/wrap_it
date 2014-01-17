module WrapIt
  #
  # Adds switches functionality
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Switches
    def self.included(base)
      base <= Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base subclasses"
      )
      extend DerivedAttributes
      base.extend ClassMethods
      # include :after_initialize callback only once
      base.after_initialize :switches_init if base == Base
    end

    private

    def switches_init
      switches = self.class.collect_derived(:@switches, {}, :merge)
      keys = switches.keys
      keys.each { |switch| instance_variable_set("@#{switch}", false) }
      @options.keys.select { |o| keys.include?(o) }.each do |switch|
        send("#{switches[switch][:name]}=", @options.delete(switch) == true)
      end
      @arguments.extract!(Symbol, and: [keys]).each do |switch|
        send("#{switches[switch][:name]}=", true)
      end
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
      # @param  name [String, Symbol] Switch name. Converted to `Symbol`.
      # @param  options = {} [Hash] Switch options
      # @options options [String, Symbol, Array<String, Symbol>] :html_class
      #   HTML class that will automatically added to element if switch is on
      #   or removed from element if switch id off.
      # @options options [Symbol, Array<Symbol>] :aliases list of aliases.
      #   Warning! Values are not converted - pass only `Symbols` here.
      # @yield [state] Runs block when switch state changed, gives it to block.
      # @yieldparam state [Boolean] Whether switch is on or off.
      # @yieldreturn [void]
      #
      # @return [void]
      def switch(name, options = {}, &block)
        options.symbolize_keys!
        name = name.to_sym
        options.merge!(block: block, name: name)
        names = [name] + [[options[:aliases]] || []].flatten.compact
        var = "@#{name}".to_sym
        define_method("#{name}?") { instance_variable_get(var) == true }
        define_method("#{name}=") do |value|
          instance_variable_set(var, value == true)
          if value == true
            options.key?(:html_class) && add_html_class(options[:html_class])
            block.nil? || instance_exec(true, &block)
          else
            options.key?(:html_class) &&
              remove_html_class(options[:html_class])
            block.nil? || instance_exec(false, &block)
          end
        end
        @switches ||= {}
        names.each { |n| @switches[n] = options }
      end
    end
  end
end
