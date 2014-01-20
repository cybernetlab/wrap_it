module WrapIt
  #
  # Describes elements that can contain other elements
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  # TODO: single_child
  class Container < Base
    switch :deffered_render do |_|
      # avoid changing deffered_render after any child added
      if @children.is_a?(Array)
        @children.empty?
      else
        true
      end
    end

    attr_reader :children
    attr_writer :extract_children
    section :children

    def extract_children?
      @extract_children == true
    end

    after_initialize do
      @children = []
      self.class.extract_from_options.each do |option, name|
        args = options.delete(option)
        next if args.nil?
        args = [args] unless args.is_a?(Array)
        self.deffered_render = true
        send(name, *args)
      end
    end

    #
    # Defines child elements helper for creation of child items.
    #
    # @return [String]
    def self.child(name, *args, &block)
      name.is_a?(String) && name.to_sym
      name.is_a?(Symbol) || fail(ArgumentError, 'Wrong child name')
      child_class =
        if args.first.is_a?(String) || args.first.is_a?(Class)
          args.shift
        else
          'WrapIt::Base'
        end
      child_class = child_class.name if child_class.is_a?(Class)
      @helpers ||= []
      @helpers << name
      define_method name do |*helper_args, &helper_block|
        # We should clone arguments becouse if we have loop in template,
        # `extract_options!` below works only for first iterration
        default_args = args.clone
        options = helper_args.extract_options!
        options[:helper_name] = name
        options.merge!(default_args.extract_options!)
        helper_args += default_args + [options]
        add_children(name, child_class, block, *helper_args, &helper_block)
      end
    end

    def self.extract_from_options(*args)
      return @extract_from_options || [] if args.size == 0
      hash = args.extract_options!
      args.size.odd? && fail(ArgumentError, 'odd arguments number')
      args.each_with_index { |arg, i| i.even? && hash[arg] = args[i + 1] }
      @helpers ||= []
      hash.symbolize_keys!
      @extract_from_options = Hash[
        hash.select do |k, v|
          (v.is_a?(String) || v.is_a?(Symbol)) && @helpers.include?(k)
        end.map { |k, v| [k, v.to_sym] }
      ]
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

    def add_children(name, helper_class, class_block, *args, &helper_block)
      options = args.extract_options!
      section = options.delete(:section) || :children
      args << options
      item = Object
        .const_get(helper_class)
        .new(@template, *args, &helper_block)
      item.instance_variable_set(:@render_to, section)
      item.instance_variable_set(:@parent, self)
      item.define_singleton_method(:render_to) { @render_to }
      item.define_singleton_method(:render_to=) do |value|
        self.class.sections.include?(value) && @render_to = value
      end
      item.define_singleton_method(:parent) { @parent }
      class_block.nil? || instance_exec(item, &class_block)

      deffered_render? && @children << item
      if !deffered_render? && (omit_content? || extract_children?)
        self[section] << capture { item.render }
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
  end
end
