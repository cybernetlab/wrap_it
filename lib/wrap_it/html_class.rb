module WrapIt
  #
  # Methods for manipulationg with HTML class. For internal usage.
  # You should not include this class directly - subclass from
  # `WrapIt::Base` instead.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module HTMLClass
    extend DerivedAttributes

    def self.included(base)
      base <= Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base subclasses"
      )
      base.extend ClassMethods
    end

    #
    # html class getter
    #
    # @return [Array<String>] array of html classes of element
    def html_class
      @options[:class]
    end

    #
    # Sets html class(es) for element
    # @param  value [Symbol, String, Array<Symbol, String>] HTML class or list
    #   of classes. All classes will be converted to Strings, duplicates are
    #   removed.
    # @return [void]
    #
    # @example
    #   element.html_class = [:a, 'b', ['c', :d, 'a']]
    #   element.html_class #=> ['a', 'b', 'c', 'd']
    def html_class=(value)
      @options[:class] = []
      add_html_class(value)
    end

    #
    # Adds html class(es) to element. Chaining allowed. All classes will be
    # converted to Strings, duplicates are removed.
    # @override add_html_class([[html_class], ...])
    # @param  html_class [Symbol, String, Array<Symbol, String>]
    #   HTML class or list of HTML classes.
    # @return [self]
    #
    # @example
    #   element.html_class = 'a'
    #   element.add_html_class :b, :c, ['d', :c, :e, 'a']
    #   element.html_class #=> ['a', 'b', 'c', 'd', 'e']
    def add_html_class(*args)
      @options[:class] += args.flatten.map { |c| c.to_s }
      @options[:class].uniq!
      self # allow chaining
    end

    #
    # Removes html class(es) from element. Chaining allowed
    # @override add_html_class([[html_class], ...])
    # @param html_class [Symbol, String, Regexp, Array<Symbol, String, Regexp>]
    #   HTML class or list of HTML classes.
    # @return [self]
    #
    # @example
    #   element.add_html_class %w(a b c d e)
    #   element.remove_html_class :b, ['c', :e]
    #   element.html_class #=> ['a', 'd']
    def remove_html_class(*args)
      args.flatten!
      re = []
      args.reject! { |c| c.is_a?(Regexp) && re << c && true }
      args = args.uniq.map { |c| c.to_s }
      args.size > 0 && @options[:class].reject! { |c| args.include?(c) }
      re.is_a?(Array) && re.each do |r|
        @options[:class].reject! { |c| r.match(c) }
      end
      self # allow chaining
    end

    #
    # Determines whether element contains class, satisfied by conditions,
    # specified in method arguments.
    #
    # There are two forms of method call: with list of conditions as arguments
    # and with block for comparing. Method makes comparison with html class
    # untill first `true` return value or end of list. All conditions should
    # be satisfied for `true` return of this method.
    #
    # In first form, each argument treated as condition. Condition can be a
    # `Regexp`, so html classes of element tested for matching to that
    # regular expression. If condition is an `Array` then every class will be
    # tested for presence in this array. If condition is `Symbol` or `String`
    # classes will be compared with it via equality operator `==`.
    #
    # In second form all arguments are ignored and for each comparison given
    # block called with html class as argument. Block return value then used.
    #
    # @overload html_class([condition, ...])
    # @param condition [<Regexp, Symbol, String, Array<String>]
    #   condition for comparison.
    #
    # @overload html_class(&block)
    # @yield [html_class] Gives each html class to block. You should return
    #   `true` if element contains this html class.
    # @yieldparam html_class [String] html class to inspect.
    # @yieldreturn [Boolean] whether element has html class.
    #
    # @return [Boolean] whether element has class with specified conditions.
    #
    # @example with `Symbol` or `String` conditions
    #   element.html_class = [:a, :b, :c]
    #   element.html_class?(:a)       #=> true
    #   element.html_class?(:d)       #=> false
    #   element.html_class?(:a, 'b')  #=> true
    #   element.html_class?(:a, :d)   #=> false
    #
    # @example with `Regexp` conditions
    #   element.html_class = [:some, :test]
    #   element.html_class?(/some/)         #=> true
    #   element.html_class?(/some/, /bad/)  #=> false
    #   element.html_class?(/some/, :test)  #=> true
    #
    # @example with `Array` conditions
    #   element.html_class = [:a, :b, :c]
    #   element.html_class?(%w(a d)) #=> true
    #   element.html_class?(%w(e d)) #=> false
    #
    # @example with block
    #   element.html_class = [:a, :b, :c]
    #   element.html_class? { |x| x == 'a' } #=> true
    def html_class?(*args, &block)
      args.all? { |c| inspect_class(:any?, c, &block) }
    end

    #
    # Determines whether element doesn't contains class, satisfied by
    # conditions, specified in method arguments.
    #
    # @see html_class?
    def no_html_class?(*args, &block)
      args.all? { |c| inspect_class(:none?, c, &block) }
    end

    protected

    def add_default_classes
      add_html_class self.class.collect_derived(:@html_class)
    end

    private

    def inspect_class(with, value = nil, &block)
      if block_given?
        @options[:class].send(with, &block)
      else
        case
        when value.is_a?(Regexp)
          @options[:class].send(with) { |c| value.match(c) }
        when value.is_a?(String) || value.is_a?(Symbol)
          @options[:class].send(with) { |c| value.to_s == c }
        when value.is_a?(Array)
          @options[:class].send(with) { |c| value.include?(c) }
        else
          false
        end
      end
    end

    #
    # Class methods to include
    #
    module ClassMethods
      #
      # @dsl
      # Adds default html classes, thats are automatically added when element
      # created.
      # @override html_class([html_class, ...])
      # @param  html_class [String, Symbol, Array<String, Symbol>] HTML class.
      #   Converted to `String`
      #
      # @return [void]
      def html_class(*args)
        @html_class ||= []
        @html_class += args.flatten.map { |c| c.to_s }
        @html_class.uniq!
      end
    end
  end
end
