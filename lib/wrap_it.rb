require 'wrap_it/no_rails' unless defined? Rails

#
# Main routines
#
# @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
#
module WrapIt
  #
  module Helpers; end

  def self.helpers(*list)
    @helpers ||= {}
    options = list.extract_options!
    list.empty? && list = @helpers.keys
    prefix = options[:prefix].blank? ? '' : "#{options[:prefix]}_"
    helpers_hash = @helpers
    Helpers.module_eval do
      list.each do |helper|
        define_method "#{prefix}#{helper}" do |*args, &block|
          opts = args.extract_options!
          opts[:helper_name] = helper
          args.push opts
          obj = Object.const_get(helpers_hash[helper]).new(self, *args, &block)
          obj.render
        end
      end
    end
    Helpers
  end

  def self.register(*args)
    class_name = args.pop
    !class_name.is_a?(String) && fail(
      ArgumentError,
      "Last argument for #{name}.register_helper should be a class name"
    )
    @helpers ||= {}
    args.each do |arg|
      !arg.is_a?(Symbol) && fail(
        ArgumentError,
        "First arguments for #{name}.register_helper" \
        " should be Symbols with helper names"
      )
      @helpers.key?(arg) && fail(
        ArgumentError,
        "Helper #{arg} for #{name}.register_helper allready exists"
      )
      @helpers[arg] = class_name
    end
  end

  def self.unregister(*helpers)
    @helpers ||= {}
    helpers.each do |helper|
      helper.is_a?(String) && helper = helper.to_sym
      next unless helper.is_a? Symbol
      @helpers.delete(helper)
    end
  end
end

require 'wrap_it/derived_attributes'
require 'wrap_it/callbacks'
require 'wrap_it/arguments_array'
require 'wrap_it/html_class'
require 'wrap_it/html_data'
require 'wrap_it/switches'
require 'wrap_it/enums'
if defined? Rails
  require 'wrap_it/rails'
else
end
require 'wrap_it/base'
require 'wrap_it/container'
require 'wrap_it/text_container'
require 'wrap_it/link'
