module WrapIt
  #
  # Adds #capture! and #capture_first! methods to array. Theese methods are
  # extracts items from array by some conditions and returns its as separate
  # array for #capture! and as first item for #capture_first!.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module CaptureArray
    REQUIRED_METHODS = %i(reject! find_index delete_at)

    #
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
    # Extracts elements from array by conditions, passed in arguments and
    # returns theese elements as new array.
    #
    # Condition can be Regexp, Class, Array, lambdas and any other value.
    # if condition contains labdas, all off them will be called before
    # tests and results of theese calls will be used as conditions.
    #
    # If condition is `Regexp`, all elements of array are tested for matching
    # to this regexp, previously converted to String by their `to_s` method. If
    # condition is an `Array`, all elements tested if it included in these
    # array. If the condition is a class, then elements are tested via `is_a?`
    # method for this class. `true` and `false` conditions do exactly what it
    # mean - `true` will satisfy condition, `false` will not. For any other
    # value, elements are tested with equality operator `==`.
    #
    # You can provide a block. In this case, all arguments are ignored, and
    # block yielded for each element of array. If block returns `true`,
    # element extracted from array.
    #
    # All conditions, passed as arguments are `or`-ed so `String, Symbol` means
    # select Symbol or String elements.
    #
    # You can also specify `and` option, so all tests will be and'ed with its
    # conditions.
    #
    # @overload capture!([condition, ...], opts = {})
    #   @param condition [Object] one of `or`-ed conditions for comparing
    #   @param opts [Hash] options for extracting
    #   @option opts [Object, Array] :and one or array of `and`-ed conditions
    #
    # @overload capture!(&block)
    #   @yield [element] Gives each element of array to block. You should
    #     return `true` to capture this element or `false` to keep it in array.
    #   @yieldparam [Object] element element of array to inspect
    #   @yieldreturn [Boolean] whether exclude this element or not
    #
    # @return [Array] array of captured elements
    #
    # @example capture by class
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::CaptureArray
    #   arr.capture(String) #=> ['and', 'string']
    #   arr                 #=> [1, 2, 3]
    #
    # @example capture by value
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::CaptureArray
    #   arr.capture(1, 2) #=> [1, 2]
    #   arr               #=> [3, 'and', 'string']
    #
    # @example capture by Regexp
    #   arr = [1, 2, 3, 'and', 'string', :str]
    #   arr.extend WrapIt::CaptureArray
    #   arr.capture(/^str/) #=> ['string', :str]
    #   arr                 #=> [1, 2, 3, 'and']
    #
    # @example capture by Array
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::CaptureArray
    #   arr.capture([1, 10, 'and']) #=> [1, 'and']
    #   arr                         #=> [2, 3, 'string']
    #
    # @example capture by block
    #   arr = [1, 2, 3, 'and', 'string']
    #   arr.extend WrapIt::CaptureArray
    #   arr.capture {|x| x < 3} #=> [1, 2]
    #   arr                     #=> [3, 'and', 'string']
    #
    # @example capture with `and` condition
    #   arr = [1, 2, 3, 'and', 'string', :str]
    #   arr.extend WrapIt::CaptureArray
    #   arr.capture(String, and: [/^str/]) #=> ['string']
    #   arr                                #=> [1, 2, 3, 'and', :str]
    def capture!(*args, &block)
      captureed = []
      reject! do |arg|
        do_compare(arg, *args, &block) && (captureed << arg) && true
      end
      captureed
    end

    #
    # Extracts first element from array that is satisfy conditions, passed in
    # arguments and returns these element.
    #
    # @see #capture!
    def capture_first!(*args, &block)
      index = find_index { |arg| do_compare(arg, *args, &block) }
      index.nil? ? nil : delete_at(index)
    end

    private

    # @private
    def do_compare(target, *compare_args, &block)
      return yield target if block_given?
      options = compare_args.extract_options!
      compare_args.map! { |x| x.is_a?(Proc) && x.lambda? ? x.call : x }
      result = compare_args.any? do |dest|
        case
        when dest == true || dest == false then dest
        when dest.is_a?(Array) then dest.include?(target)
        when dest.is_a?(Regexp) then dest.match(target.to_s)
        when dest.is_a?(Class) then target.is_a?(dest)
        when dest.is_a?(Proc) then dest.call(dest) == true
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
