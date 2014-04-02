module WrapIt
  #
  # Describes elements that can contain other elements
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  # @todo  single_child realization
  # @todo  refactor code for more clearness
  class Container < Base
    using EnsureIt if ENSURE_IT_REFINED

    switch :deffered_render do |_|
      # avoid changing deffered_render after any child added
      if @children.is_a?(Array)
        @children.empty?
      else
        true
      end
    end

    # list of children elements
    attr_reader :children

    # children can be extracted from normal template flow and rendered in
    # separate section.
    attr_writer :extract_children

    section :children

    def extract_children?
      @extract_children == true
    end

    before_initialize do
      @children = []
    end

    #
    # Defines helper for child elements creation.
    #
    # @example  simple usage
    #   class Item < WrapIt::Base
    #     include TextContainer
    #   end
    #
    #   class List < WrapIt::Container
    #     default_tag 'ul'
    #     child :item, tag: 'li'
    #   end
    #
    #   list = List.new(template)
    #   list.item 'list item 1'
    #   list.item 'list item 2'
    #   list.render # => '<ul><li>list item 1'</li><li>list item 2</li></ul>'
    #
    # @example  with option
    #   class Button < WrapIt::Container
    #     include TextContainer
    #     html_class 'btn'
    #     child :icon, tag: 'i', option: true
    #   end
    #
    #   btn = Button.new(template, 'Home', icon: { class: 'i-home' })
    #   btn.render # => '<div class="btn">Home<i class="i-home"></i></div>'
    #
    # @overload child(name, class_name = nil, [args, ...], opts = {}, &block)
    #   @param name [Symbol, String] helper method name
    #   @param class_name [String, Base] class for child elements. If ommited
    #     WrapIt::Base will be used
    #   @param args [Object] any arguments that will be passed to child
    #     element constructor
    #   @param opts [Hash] options
    #   @option opts [true, Symbol] :option if specified, child can be created
    #     via option with same name (if :option is true) or with specified
    #     name
    #   @option opts [Symbol] :section section to that this children will be
    #     rendered. By default children rendered to `children`. Refer to
    #     {Sections} module for details.
    #
    # @return [String]
    def self.child(name, *args, option: nil, **opts, &block)
      name.ensure_symbol!
      child_class =
        if args.first.is_a?(String) || args.first.is_a?(Class)
          args.shift
        else
          'WrapIt::Base'
        end
      child_class = child_class.name if child_class.is_a?(Class)

      define_method name do |*hargs, extracted: false, **hopts, &hblock|
        hargs += args
        html_class = opts.delete(:class)
        unless html_class.nil?
          html_class = html_class.split(' ') if html_class.is_a?(String)
          if hops[:class].is_a?(String)
            hopts[:class] << ' ' << html_class.join(' ')
          elsif hopts[:class].is_a?(Array)
            hopts[:class].concat(html_class)
          else
            hopts[:class] = html_class
          end
        end
        html_data = opts.delete(:data)
        unless html_data.nil?
          if hops[:data].is_a?(Hash)
            hopts[:data].merge!(html_data)
          else
            hopts[:data] = html_data
          end
        end
        hopts.merge!(opts)
        hopts[:helper_name] = name
        child = prepare_child(child_class, block, *hargs, **hopts, &hblock)
        add_children(name, child, extracted: extracted)
      end

      add_child_option(name, option)
    end

    after_capture do
      if deffered_render?
        html = Hash[children.map { |c| [c.object_id, capture { c.render }] }]
        unless omit_content? || extract_children?
          safe = html_safe?(self[:content])
          self[:content] = self[:content]
            .split(CONTENT_SPLIT_REGEXP)
            .reduce(empty_html) do |a, e|
              match = CONTENT_REPLACE_REGEXP.match(e)
              safe && e = html_safe(e)
              str = match.nil? ? e : html.delete(match[:obj_id].to_i(16))
              a << (str || empty_html)
            end
        end
        # finally add all elements, not captured from markup
        html.each do |id, str|
          obj = ObjectSpace._id2ref(id)
          obj.nil? || self[obj.render_to] << str
        end
      end
    end

    private

    CONTENT_SPLIT_REGEXP = /(<!-- WrapIt::Container\(\h+\) -->)/
    CONTENT_REPLACE_REGEXP = /\A<!-- WrapIt::Container\((?<obj_id>\h+)\) -->\z/

    def add_children(name, item, extracted: false)
      deffered_render? && @children << item
      return if extracted == true
      if !deffered_render? && (omit_content? || extract_children?)
        self[item.render_to] << capture { item.render }
      end
      if omit_content? || extract_children?
        empty_html
      else
        if deffered_render?
          html_safe("<!-- WrapIt::Container(#{item.object_id.to_s(16)}) -->")
        else
          item.render
        end
      end
    end

    def prepare_child(helper_class, class_block, *args,
                      section: nil, **opts,
                      &helper_block)
      section ||= :children
      item = Object
        .const_get(helper_class)
        .new(@template, *args, **opts, &helper_block)
      item.instance_variable_set(:@render_to, section)
      item.instance_variable_set(:@parent, self)
      item.define_singleton_method(:render_to) { @render_to }
      item.define_singleton_method(:render_to=) do |value|
        self.class.sections.include?(value) && @render_to = value
      end
      item.define_singleton_method(:parent) { @parent }
      class_block.nil? || instance_exec(item, &class_block)
      item
    end

    def self.add_child_option(name, option)
      return if option.nil?
      option.is_a?(Array) || option = [option]
      option.each do |opt_name|
        opt_name = name if opt_name == true
        option(opt_name) do |_, args|
          self.deffered_render = true
          args.is_a?(Array) || args = [args]
          opts = args.extract_options!
          send(name, *args, extracted: true, **opts)
        end
      end
    end
  end
end
