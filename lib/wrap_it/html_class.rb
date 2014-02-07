require 'delegate'

module WrapIt
  #
  # Provides array-like access to HTML classes.
  #
  # This class delegate allmost all methods to underlying array with some
  # value checking and modification. Also it restrict a list of methods,
  # exposed below becouse call to theese methods unusefull in context of HTML
  # class list.
  #
  # Some methods, thats described in this document have different manner.
  # See each method description for details.
  #
  # All other methods can be used as with standard array
  #
  # Restricted methods: assoc, bsearch, combination, compact, compact!, fill,
  # flatten, flatten!, insert, pack, permutation, product, rassoc,
  # repeated_combination, rotate, repeated_permutation, reverse reverse!,
  # reverse_each, sample, rotate!, shuffle, shuffle!, sort, sort!, sort_by!,
  # transpose, uniq, uniq!, zip, flat_map, max, max_by, min, min_by, minmax,
  # minmax_by
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class HTMLClass < DelegateClass(Array)
    #
    # Sanitizes and normalizes HTML class. Makes array of classes flatten,
    # removes all duplicates, splits spaced strings.
    #
    # @param  values [Object] can be a symbol, string, array of symbols and
    #   strings, array of strings, strings can contains spaces.
    #
    # @return [Array<String>] sanitized list of HTML classes
    def self.sanitize(*values)
      values
        .flatten
        .each_with_object([]) do |i, a|
          a << i.to_s if i.is_a?(String) || i.is_a?(Symbol)
        end
        .join(' ')
        .strip
        .split(/\s+/)
        .uniq
    end

    def initialize(value = [])
      super(HTMLClass.sanitize(value))
    end

    # Array overrides

    # with array argument and new array return
    %i(& + - concat |).each do |method|
      define_method method do |values|
        HTMLClass.new(__getobj__.send(method, HTMLClass.sanitize(values)))
      end
    end

    # array process, returning new array
    %i(collect drop_while map reject select).each do |method|
      define_method method do |&block|
        result = __getobj__.send(method, &block)
        result.is_a?(Array) ? HTMLClass.new(result) : result
      end
    end

    # bang! array process
    %i(collect! map! reject!).each do |method|
      define_method method do |&block|
        obj = __getobj__
        result = obj.send(method, &block)
        obj.replace(HTMLClass.sanitize(obj))
        result.is_a?(Array) ? self : result
      end
    end

    # non-bang array process, returning self
    %i(each each_index keep_if select!).each do |method|
      define_method method do |&block|
        result = __getobj__.send(method, &block)
        result.is_a?(Array) ? self : result
      end
    end

    %i(<< concat).each do |method|
      define_method method do |values|
        data = __getobj__ + HTMLClass.sanitize(values)
        __setobj__(data.uniq)
        self
      end
    end

    # with any args, returning some obj or new array
    %i([] drop first last pop shift slice! values_at).each do |method|
      define_method method do |*args|
        result = __getobj__.send(method, *args)
        result.is_a?(Array) ? HTMLClass.new(result) : result
      end
    end
    alias_method :slice, :[]

    # @private
    def clear
      __getobj__.clear
      self
    end


    #
    # Removes elements from list by some conditions.
    #
    # See {#index} for condition details
    #
    # @overload  delete([cond, ...], &block)
    #   @param  cond [Symbol, String, Array<String>, Regexp] [description]
    #   @param  &block [Proc] searching block
    #
    # @return [self]
    def delete(*args, &block)
      obj = __getobj__
      args.each do |x|
        i = index(x)
        next if i.nil? || i.is_a?(Enumerator)
        obj.delete_at(i)
      end
      unless block.nil?
        i = index(&block)
        i.nil? || obj.delete_at(i)
      end
      self
    end

    #
    # Searches HTML classes by conditions
    #
    # Conditions can be a Symbol, String, Array of strings or Regexp. Or you
    # can provide block for searching.
    #
    # For Strings and Symbols array-like search used (symbols converted to
    # strings). For Array conditions, any value from this array will match.
    # For Regexp - regular expression matcher will used.
    #
    # @param  value [nil, Symbol, String, Array<String>, Regexp] condition
    # @param  block [Proc] searching block
    #
    # @return [nil, Number] index of finded item or nil
    def index(value = nil, &block)
      value.is_a?(Symbol) && value = value.to_s
      value.is_a?(Array) && value.map! { |x| x.to_s }
      case
      when value.is_a?(Regexp) then __getobj__.index { |x| value =~ x }
      when value.is_a?(Array) then __getobj__.index { |x| value.include?(x) }
      when block_given? then __getobj__.index(&block)
      when value.nil? then __getobj__.index
      else __getobj__.index(value)
      end
    end
    alias_method :rindex, :index

    #
    # Determines whether HTML classes have class, matching conditions
    #
    # @overload  include?([cond, ...])
    #   @param  cond [Symbol, String, Array<String>, Regexp] [description]
    #
    # @return [Boolean] whether HTML classes include specified class
    def include?(*args)
      args.all? do |x|
        x.is_a?(Proc) ? !index(&x).nil? : !index(x).nil?
      end
    end

    #
    # Combines all classes, ready to insert in HTML.
    #
    # Actually just join all values with spaces
    #
    # @return [String] html string
    def to_html
      __getobj__.join(' ')
    end

    %i(replace).each do |method|
      define_method method do |*values|
        __getobj__.send(method, HTMLClass.sanitize(values))
        self
      end
    end

    %i(push unshift).each do |method|
      define_method method do |*values|
        __getobj__.send(method, *HTMLClass.sanitize(values))
        __getobj__.uniq!
        self
      end
    end

    # Restricted functions
    %i(
      * []= assoc bsearch combination compact compact! fill flatten flatten!
      insert pack permutation product rassoc repeated_combination rotate
      repeated_permutation reverse reverse! reverse_each sample rotate! shuffle
      shuffle! sort sort! sort_by! transpose uniq uniq! zip flat_map max max_by
      min min_by minmax minmax_by
    ).each do |method|
      define_method(method) do
        raise "Method #{method} is not supported for HTMLClass"
      end
    end

    # Enumerable overrides
  end
end
