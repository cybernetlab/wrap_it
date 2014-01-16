module WrapIt
  #
  # Adds #extract! and #extarct_first! methods to array. Theese methods are
  # extracts items from array by some condirions and returns its as separate
  # array for #extract! and as first item for #extract_first!.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module ArgumentsArray
    REQUIRED_METHODS = %i(reject! find_index delete_at)

    def self.included(base)
      methods = base.methods
      # avoid including in classes thats doen't have methods, used in
      # inplementation
      REQUIRED_METHODS.all? { |m| methods.include?(m) } || fail(
        TypeError,
        "#{self.class.name} can't be included into #{base.class.name}"
      )
    end
    #
    # Extracts elements from array by conditions, passed in arguments nad
    # returns theese elements as new array.
    #
    # Condition can be Regexp, class, Array and any other value. If condition
    # is `Regexp`, all elements of array are tested for matching to this
    # regexp, previously converted to String by their `to_s` method. If
    # condition is an `Array`, all elements tested if it included in these
    # array. If the condition is a class, then elements are tested via `is_a?`
    # method for this class. For any other value, elements are tested with
    # equality operator `==`.
    #
    # You can provide a block. In this case, all arguments are ignored, and
    # block yielded for each element of array. If block returns `true`,
    # element extracted from array.
    #
    # All conditions, passed as arguments are `or`-ed so `String, Symbol` means
    # select Symbol or String elements.
    #
    # @overload extract!([condition, ..., options])
    # @param [Object] condition one of `or`-ed conditions for comparing
    # @param [Hash] options options for axtracting
    # @options options [Object, Array] :and one or array of `and`-ed conditions
    #
    # @overload extract!(&block)
    # @yield [element] Gives each element of array to block. You should return
    #   `true` to extract this element or `false` to keep it in array.
    # @yieldparam [Object] element element of array to inspect
    # @yieldreturn [Boolean] whether exclude this element or not
    #
    # @return [Array] array of extracted elements
    #
    # @example extract by class
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::ArgumentsArray
    #   arr.extract(String) #=> ['and', 'string']
    #   arr                 #=> [1, 2, 3]
    #
    # @example extract by value
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::ArgumentsArray
    #   arr.extract(1, 2) #=> [1, 2]
    #   arr               #=> [3, 'and', 'string']
    #
    # @example extract by Regexp
    #   arr = [1, 2, 3, 'and', 'string', :str]
    #   arr.extend WrapIt::ArgumentsArray
    #   arr.extract(/^str/) #=> ['string', :str]
    #   arr                 #=> [1, 2, 3, 'and']
    #
    # @example extract by Array
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::ArgumentsArray
    #   arr.extract([1, 10, 'and']) #=> [1, 'and']
    #   arr                         #=> [2, 3, 'string']
    #
    # @example extract by block
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::ArgumentsArray
    #   arr.extract {|x| x < 3} #=> [1, 2]
    #   arr                     #=> [3, 'and', 'string']
    #
    # @example extract with `and` condition
    #   arr = [1, 2, 3, 'and', 'string', :str]
    #   arr.extend WrapIt::ArgumentsArray
    #   arr.extract(String, and: [/^str/]) #=> ['string']
    #   arr                                #=> [1, 2, 3, 'and', :str]
    def extract!(*args, &block)
      extracted = []
      reject! do |arg|
        do_compare(arg, *args, &block) && extracted << arg && true
      end
      extracted
    end

    #
    # Extracts first element from array that is satisfy conditions, passed in
    # arguments and returns these element.
    #
    # @see #extract!
    def extract_first!(*args, &block)
      index = find_index { |arg| do_compare(arg, *args, &block) }
      index.nil? ? nil : delete_at(index)
    end

    private

    def do_compare(target, *compare_args)
      if block_given?
        yield target
      else
        options = compare_args.extract_options!
        result = compare_args.any? do |dest|
          case
          when dest.is_a?(Array) then dest.include?(target)
          when dest.is_a?(Regexp) then dest.match(target.to_s)
          when dest.is_a?(Class) then target.is_a?(dest)
          else dest == target
          end
        end
        if options[:and].is_a?(Array)
          result &&= do_compare(target, *options[:and])
        end
        result
      end
    end
  end
end
