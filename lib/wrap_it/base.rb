module WrapIt
  #
  # Base class for all HTML helper classes
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class Base
    include DerivedAttributes
    include Callbacks

    callback :initialize, :capture, :render

    include HTMLClass
    include Switches
    include Enums
    include Renderer

    @omit_content = false

    attr_reader :tag
    attr_reader :options

    def initialize(template, *args, &block)
      @template, @arguments, @block = template, args, block
      self.options = @arguments.extract_options!
      @arguments.extend ArgumentsArray
      add_default_classes
      run_callbacks :initialize do
        @tag = @options.delete(:tag) ||
          self.class.get_derived(:@default_tag) || 'div'
        @helper_name = @options.delete(:helper_name)
        @helper_name.is_a?(String) && @helper_name = @helper_name.to_sym
      end
      @argument = nil
    end

    def omit_content?
      self.class.get_derived(:@omit_content)
    end

    def render(*args, &render_block)
      # return cached copy if it available
      return @content unless @content.nil?
      @content = empty_html

      # capture content from block
      do_capture
      # add to content string args and block result if its present
      args.flatten.each { |a| @content << a if a.is_a? String }
      block_given? && @content << instance_exec(self, &render_block)

      # cleanup options from empty values
      @options.select! { |k, v| !v.nil? && !v.empty? }
      # render element
      run_callbacks :render do
        @content = content_tag(@tag, @content, @options)
      end

#      @content = @wrapper.render(@content.html_safe) if @wrapper.is_a?(Base)
      if @template.output_buffer.nil?
        # when render called from code, just return content as a String
        @content
      else
        # in template context, write content to templates buffer
        concat(@content)
        empty_html
      end
    end

    protected

    #
    # @dsl
    # Defines default tag name for element. This tag can be changed soon.
    # @param  name [<Symbol, String>] Tag name. Converted to `String`.
    #
    # @return [void]
    def self.default_tag(name)
      name.is_a?(String) || name.is_a?(Symbol) ||
        fail(ArgumentError, 'Tag name should be a String or Symbol')
      @default_tag = name.to_s
    end

    def self.omit_content
      @omit_content = true
    end

    def options=(hash)
      hash.is_a?(Hash) || return
      hash.symbolize_keys!

      # sanitize class
      hash[:class] ||= []
      hash[:class] = [hash[:class]] unless hash[:class].is_a?(Array)
      hash[:class] = hash[:class].map { |c| c.to_s }.uniq
      @options = hash
    end

    def do_capture
      run_callbacks :capture do
        @content ||= empty_html
        unless @block.nil? || omit_content?
          @content << (capture(self, &@block) || empty_html)
        end
      end
    end
  end
end
