module WrapIt
  #
  # Base class for all HTML helper classes
  #
  # @example Prevent user from changing element tag
  #   class Helper < WrapIt::Base
  #     after_initialize { @tag = 'table' }
  #   end
  # @example Including some simple HTML into content
  #   class Helper < WrapIt::Base
  #     after_initialize do
  #       @icon = optioins.delete(:icon)
  #     end
  #     after_capture do
  #       unless @icon.nil?
  #       @content = html_safe("<i class=\"#{@icon}\"></i>") + @content
  #     end
  #   end
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class Base
    # Documentation includes
    #
    # @!parse extend  Arguments::ClassMethods
    # @!parse extend  Enums::ClassMethods
    # @!parse extend  HTML::ClassMethods
    # @!parse extend  Sections::ClassMethods
    # @!parse extend  Switches::ClassMethods

    #
    # include appropriate functionality from modules
    include DerivedAttributes
    include Callbacks

    callback :initialize, :capture, :render

    include Arguments
    include Sections
    include HTML
    include Switches
    include Enums
    include Renderer

    @omit_content = false

    attr_reader :helper_name
    option :helper_name
    option :tag
    section :content, :render_arguments, :render_block
    place :content, :after, :begin
    place :render_block, :after, :begin
    place :render_arguments, :after, :begin

    def initialize(template, *args, &block)
      @template, @block = template, block
      add_default_classes
      run_callbacks :initialize do
        capture_arguments!(args, &block)
        # TODO: uncomment following after html_attr implementation finished
        #html_attr.merge!(args.extract_options!)
        self.html_attr = args.extract_options!
        # TODO: find convenient way to save unprocessed arguments
        @arguments = args
      end
    end

    def tag
      @tag ||= (self.class.get_derived(:@default_tag) || 'div').to_s
    end

    def tag=(value)
      value.is_a?(Symbol) && value = value.to_s
      value.is_a?(String) && @tag = value
    end

    def helper_name=(value)
      value.is_a?(String) && value = value.to_sym
      value.is_a?(Symbol) && @helper_name = value
    end

    def omit_content?
      self.class.get_derived(:@omit_content) == true
    end

    #
    # Renders element to template
    #
    # @overload render([content, ...])
    #   @param content [String] additional content that will be appended
    #                           to element content
    #   @yield [element] Runs block after capturing element content and before
    #                    rendering it. Returned value appended to content.
    #   @yieldparam element [Base] rendering element.
    #   @yieldreturn [String, nil] content to append to HTML
    #
    # @return [String] rendered HTML for element
    def render(*args, &render_block)
      # return cached copy if it available
      return @rendered unless @rendered.nil?

      capture_sections

      # add to content string args and block result if its present
      args.flatten.each { |a| self[:render_arguments] << a if a.is_a? String }
      if block_given?
        result = instance_exec(self, &render_block) || empty_html
        result.is_a?(String) && self[:render_block] << result
      end

      do_render
      do_wrap

      if @template.output_buffer.nil?
        # when render called from code, just return content as a String
        @rendered
      else
        # in template context, write content to templates buffer
        concat(@rendered)
        empty_html
      end
    end

    #
    # Wraps element with another.
    #
    # You can provide wrapper directly or specify wrapper class as first
    # argument. In this case wrapper will created with specified set of
    # arguments and options. If wrapper class ommited, WrapIt::Base will
    # be used.
    #
    # If block present, it will be called when wrapper will rendered.
    #
    # @overload wrap(wrapper)
    #   @param  wrapper [Base] wrapper instance.
    #
    # @overload wrap(wrapper_class, [arg, ...], options = {})
    #   @param  wrapper_class [Class] WrapIt::Base subclass for wrapper.
    #   @param  arg [String, Symbol] wrapper creation arguments.
    #   @param  options [Hash] wrapper creation options.
    #
    # @overload wrap([arg, ...], options = {})
    #   @param  arg [String, Symbol] wrapper creation arguments.
    #   @param  options [Hash] wrapper creation options.
    #
    # @return [void]
    def wrap(*args, &block)
      if args.first.is_a?(Base)
        @wrapper = args.shift
      else
        wrapper_class = args.first.is_a?(Class) ? args.shift : Base
        @wrapper = wrapper_class.new(@template, *args, &block)
      end
    end

    def unwrap
      @wrapper = nil
    end

    protected

    #
    # Defines or gets default tag name for element. This tag can be changed
    # soon. Without parameters returns current default_tag value.
    # @param  name [<Symbol, String>] Tag name. Converted to `String`.
    # @param  override [Boolean] Whether to override default tag value if it
    #   allready exists.
    #
    # @return [String] new default_tag value.
    def self.default_tag(name = nil, override = true)
      return @default_tag if name.nil?
      name.is_a?(String) || name.is_a?(Symbol) ||
        fail(ArgumentError, 'Tag name should be a String or Symbol')
      override ? @default_tag = name.to_s : @default_tag ||= name.to_s
    end

    def self.omit_content
      @omit_content = true
    end

    def capture_sections
      run_callbacks :capture do
        unless @block.nil?
          captured = capture(self, &@block) || empty_html
          omit_content? || self[:content] << captured
        end
      end
    end

    def render_sections(*sections, except: nil)
      sections.empty? && sections = self.class.sections
      unless except.nil?
        except.is_a?(Array) || except = [except]
        sections.reject! { |s| except.include?(s) }
      end
      # glew sections
      self.class.placement
        .select { |s| sections.include?(s) }
        .reduce(empty_html) do |a, e|
          a << self[e]
          self[e] = empty_html
          a
        end
    end

    private

    def do_render
      # cleanup options from empty values
      html_attr.select! do |k, v|
        !v.nil? && (!v.respond_to?(:empty?) || !v.empty?)
      end
      @rendered = render_sections
      run_callbacks :render do
        options = html_attr.merge(class: html_class.to_html, data: html_data)
        @rendered = content_tag(tag, @rendered, options)
      end
    end

    def do_wrap
      @wrapper.is_a?(Base) && @rendered = capture do
        @wrapper.render(html_safe(@rendered))
      end
    end
  end
end
