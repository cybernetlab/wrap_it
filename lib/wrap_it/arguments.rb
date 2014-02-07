module WrapIt
  #
  # This module responisble to parse creation arguments in component
  # initialization process.
  #
  # Respect to ruby language, any method can take variable number of
  # arguments and a hash of options. Also you can pass a block to it. So,
  # when your component subclassed from WrapIt::Base, user can create its
  # instances via helpers. And when such component initialized you should
  # be able to process all arguments, passed to helper or constructor. Finally
  # all unprocessed options setted as component html attributes.
  #
  # Two API methods provided for this purposes - `argument` and `option`.
  # Each of them declares conditions for capturing some arguments and options.
  # Conditions applies to arguments itself or to options keys. CapturedArray
  # Array extension is used to capture arguments, so refer to its documentation
  # for conditions details.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Arguments
    # Documentation includes
    # @!parse extend  Arguments::ClassMethods

    # module implementation

    extend DerivedAttributes

    #
    def self.included(base)
      @base = base
      base.extend ClassMethods
    end

    #
    # {Arguments} Class methods to include
    #
    module ClassMethods
      #
      # Desclares argument for capturing on initialization process.
      #
      # Inside initialization process, all arguments (except options hash),
      # passed to constructor will be inspected to satisfy conditions,
      # specified in `:if` and `:and` options. If this happens, and block
      # given, it evaluated in context of component instance. If no block
      # given, setter with `name` will be attempted to set value. In any way
      # if conditions satisfied, argument removed from future processing.
      #
      # If no conditions specified, the `name` of attribute taked as only
      # condition.
      #
      # @example  without conditions - name is a condition
      #   class Button < WrapIt::Base
      #     argument(:disabled) { |name, value| puts 'DISABLED' }
      #   end
      #
      #   Button.new(template, :disabled)   # => 'DISABLED'
      #   Button.new(template, 'disabled')  # => nothing
      #
      # @example  with conditions and setter
      #   class Button < WrapIt::Base
      #     argument :disabled, if: /^disable(?:d)?$/
      #
      #     def disabled=(value)
      #       puts 'DISABLED'
      #     end
      #   end
      #
      #   Button.new(template, :disabled)   # => 'DISABLED'
      #   Button.new(template, 'disabled')  # => 'DISABLED'
      #   Button.new(template, :disable)    # => 'DISABLED'
      #   Button.new(template, 'some_text') # => nothing
      #
      # @overload argument(name, opts = {}, &block)
      #   @param  name [Symbol] unique name, used to refer to this declaration
      #   @param  opts [Hash]   options
      #   @option opts [Object]  :if one or array of conditions that should be
      #     satisfied to capture argument. See {CaptureArray} for details. If
      #     array given, conditions will be or'ed.
      #   @option opts [Object]  :and additional one or array of conditions,
      #     that will be and'ed with :if conditions.
      #   @option opts [Boolean] :first_only (false) stop processing on first
      #     match
      #   @option opts [Boolean] :after_options (false) process this argument
      #     after options
      #   @yield [name, value] yields every time argument captured. Evaluated
      #     in instance context
      #   @yieldparam name [Symbol] name of argument, specified in name param
      #     above
      #   @yieldparam value [Object] real argument value
      #
      # @return [void]
      # @since  1.0.0
      def argument(name, first_only: false, after_options: false,
                   **opts, &block)
        name.is_a?(String) && name = name.to_sym
        fail ArgumentError, 'Wrong name' unless name.is_a?(Symbol)
        arguments[name] = {
          name: name,
          conditions: Arguments.make_conditions(name, **opts),
          block: block,
          first_only: first_only == true,
          after_options: after_options == true
        }
      end

      #
      # Desclares option for capturing on initialization process.
      #
      # Provides same manner as {#argument} but for hash of options, passed
      # to constructor. Specified conditions are applied to options keys, not
      # to values.
      #
      # > Hint: you can specify argument and options with same name to call
      # > same setter.
      #
      # @example  shared setter
      #   class Button < WrapIt::Base
      #     REGEXP = /^disable(?:d)?$/
      #
      #     argument :disabled, if: REGEXP
      #     option   :disabled, if: %i(disable disabled)
      #
      #     def disabled=(value)
      #       if value == true || REGEXP =~ value.to_s
      #         puts 'DISABLED'
      #       end
      #     end
      #   end
      #
      #   Button.new(template, :disabled)       # => 'DISABLED'
      #   Button.new(template, 'disabled')      # => 'DISABLED'
      #   Button.new(template, :disable)        # => 'DISABLED'
      #   Button.new(template, disabled: true)  # => 'DISABLED'
      #   Button.new(template, disable: true)   # => 'DISABLED'
      #   Button.new(template, disable: false)  # => nothing
      #   Button.new(template, 'some_text')     # => nothing
      #
      # @overload option(name, opts = {}, &block)
      #   @param  name [Symbol] unique name, used to refer to this declaration
      #   @param  opts [Hash]   options
      #   @option opts [Object]  :if see
      #     {WrapIt::Arguments::ClassMethods#argument}
      #   @option opts [Object]  :and see
      #     {WrapIt::Arguments::ClassMethods#argument}
      #   @yield [name, value] yields every time option captured. Evaluated
      #     in instance context
      #   @yieldparam name [Symbol] name of option, specified in name param
      #     above
      #   @yieldparam value [Object] real option value
      #
      # @return [void]
      # @since  1.0.0
      def option(name, after: nil, **opts, &block)
        name.is_a?(String) && name = name.to_sym
        fail ArgumentError, 'Wrong name' unless name.is_a?(Symbol)
        @dependencies = !after.nil?
        options[name] = {
          name: name,
          conditions: Arguments.make_conditions(name, **opts),
          block: block
        }
      end


      #
      # Capture arguments for class and it's ancestors. All captured arguments
      # and options will be extracted from original `args` argument.
      #
      # Actually you rare needs to call this method directly. For example
      # you can call it in instance
      # {Arguments#capture_arguments! capture_arguments!}
      # override to capture arguments for some child components.
      #
      # @example capturing arguments for child component
      #   class Button < WrapIt::Base
      #     option(:color) { |name, value| puts "BUTTON COLOR IS: #{value}" }
      #   end
      #
      #   class Toolbar < WrapIt::Base
      #     protected
      #     def capture_arguments!(args, &block)
      #       @button = Button.new(Button.capture_arguments!(args))
      #       super(args, &block) # ! don't forget to call parent method
      #     end
      #   end
      #
      #   Toolbar.new(template, color: :red)  # => 'BUTTON COLOR IS red'
      #
      # @overload capture_arguments!(args, opts = {}, &block)
      #   @param  args [Array<Object>] arguments to process (include options)
      #   @param  opts [Hash] options
      #   @option opts [Boolean] :inherited (true) process ancestors
      #   @option opts [Base] :instance (nil) if specified valid instance,
      #     all {ClassMethods#argument} and {ClassMethods#option} blocks will
      #     and setters will be called.
      #   @param  &block [Proc] block, passed to constructor if present
      #
      # @return [Array<Object>] captured arguments
      def capture_arguments!(args, inherited = true, instance = nil, &block)
        opts = args.extract_options!
        if inherited
          ancestors.take_while { |a| a != Arguments.base }
                   .reverse
                   .unshift(Arguments.base)
                   .map do |a|
            next unless a.methods.include?(:extract_for_class)
            a.extract_for_class(args, opts, instance, &block)
          end
          result_args = collect_derived(:@provided_arguments, {}, :merge)
                        .values
                        .flatten
          result_opts = collect_derived(:@provided_options, {}, :merge)
                        .values
                        .reduce({}) { |a, e| a.merge!(e) }
        else
          extract_for_class(args, opts, instance, &block)
          result_args = @provided_arguments.values.flatten
          result_opts = @provided_options
                        .values
                        .reduce({}) { |a, e| a.merge!(e) }
        end
        opts.empty? || args << opts
        result_opts.empty? || result_args << result_opts
        result_args
      end

      protected

      attr_reader :provided_options, :provided_arguments, :provided_block

      def option_provided?(*list)
        return false if provided_options.nil?
        if list.empty?
          return provided_options.empty?
        else
          return list.all? do |option|
            provided_options.key?(option)
          end
        end
      end

      def argument_provided?(*list)
        return false if provided_arguments.nil?
        if list.empty?
          return provided_arguments.empty?
        else
          return list.all? do |arg|
            provided_arguments.key?(arg)
          end
        end
      end

      def block_provided?
        provided_block.is_a?(Proc)
      end

      def options
        @options ||= {}
      end

      def arguments
        @arguments ||= {}
      end

      def extract_args(args, list, instance = nil)
        args.respond_to?(:extract!) || args.extend(WrapIt::CaptureArray)
        list.each do |arg|
          processed =
            if arg[:first_only]
              [args.capture_first!(*arg[:conditions])].compact
            else
              args.capture!(*arg[:conditions])
            end
          (provided_arguments[arg[:name]] ||= []).concat(processed)
          next if instance.nil?
          processed.each do |v|
            instance.instance_exec(arg[:name], v, arg[:block], &SETTER)
          end
        end
      end

      def extract_opts(opts, instance = nil)
        keys = opts.keys.extend(WrapIt::CaptureArray)
        options.each do |name, opt|
          (provided_options[name] ||= {}).merge!(Hash[
            keys.capture!(*opt[:conditions])
              .map do |key|
                value = opts.delete(key)
                unless instance.nil?
                  instance.instance_exec(key, value, opt[:block], &SETTER)
                end
                [key, value]
              end
          ])
        end
      end

      def extract_for_class(args, opts, instance = nil, &block)
        @provided_options = {}
        @provided_arguments = {}
        @provided_block = block

        after, before = arguments.values.partition { |x| x[:after_options] }

        extract_args(args, before, instance)
        extract_opts(opts, instance)
        extract_args(args, after, instance)

        @provided_block = nil
      end
    end

    protected

    # @!visibility public
    #
    # Captures arguments
    #
    # In rare cases you can override this method to control directly arguments
    # capturing process. Refer to
    # {ClassMethods#capture_arguments! capture_arguments!} for examples.
    #
    # > Note that this method is `protected`, so override should be `protected`
    # > too.
    #
    # @param  args [Array<Object>] arguments, passed to constructor
    # @param  block [Proc] block, passed to constructor
    #
    # @return [Array<Object>] captured arguments
    def capture_arguments!(args, &block)
      self.class.capture_arguments!(args, true, self, &block)
    end

    private

    #
    # Evaluated in instance context by .extract_for_class
    #
    SETTER = ->(name, value, block) do
      if block.nil?
        setter = "#{name}=".to_sym
        respond_to?(setter) && send(setter, value)
      else
        instance_exec(name, value, &block)
      end
    end

    def self.normalize_conditions(cond)
      if cond.is_a?(Array) &&
         cond.any? { |x| !x.is_a?(Symbol) && !x.is_a?(String) }
        cond
      else
        [cond]
      end
    end

    def self.make_conditions(name, **opts)
      cond = normalize_conditions(opts.key?(:if) ? opts[:if] : name)
      opts.key?(:and) && cond << {and: normalize_conditions(opts[:and])}
      cond
    end

    def self.base
      @base
    end
  end
end
