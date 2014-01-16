module WrapIt
  #
  # Describes elements that can contain other elements
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class Container < Base
    switch :deffered_render

    after_initialize do
      @children = deffered_render? ? [] : empty_html
    end

    def self.child(*args, &block)
      create_args = args.last.is_a?(Array) ? args.pop : []
      klass = args.pop
      klass.is_a?(Class) && klass = klass.name
      unless klass.is_a?(String)
        args.push(klass)
        klass = 'WrapIt::Base'
      end
      args.select! { |n| n.is_a?(Symbol) }
      args.size > 0 || fail(ArgumentError, 'No valid method names given')
      args.each do |method|
        define_method method do |*helper_args, &helper_block|
          # We should clone arguments becouse if we have loop in template,
          # `extract_options!` below works only for first iterration
          default_args = create_args.clone
          options = helper_args.extract_options!
          options[:helper_name] = method
          options.merge!(default_args.extract_options!)
          helper_args += default_args + [options]
          add_children(klass, block, *helper_args, &helper_block)
        end
      end
    end

#    protected

    after_capture do
      if deffered_render?
        html = Hash[@children.map { |c| [c.object_id, capture { c.render }] }]
        if omit_content?
          @content = html.values.reduce(empty_html) { |a, e| a << e }
        else
          safe = html_safe?(@content)
          @content = @content
            .split(CONTENT_SPLIT_REGEXP)
            .reduce(empty_html) do |a, e|
              match = CONTENT_REPLACE_REGEXP.match(e)
              safe || e = html_safe(e)
              a << match.nil? ? e : html[match[:obj_id].to_i(16)]
            end
        end
      else
        omit_content? && @content = @children
      end
    end

    private

    CONTENT_SPLIT_REGEXP = /(<!-- WrapIt::Container\(\h+\) -->)/
    CONTENT_REPLACE_REGEXP = /\A<!-- WrapIt::Container\((?<obj_id>\h+)\) -->\z/

    def add_children(helper_class, class_block, *args, &helper_block)
      item = Object
        .const_get(helper_class)
        .new(@template, *args, &helper_block)
      class_block.nil? || instance_exec(item, &class_block)

      item = item.render unless deffered_render?
      @children << item if deffered_render? || omit_content?
      if omit_content?
        empty_html
      else
        if deffered_render?
          html_safe("<!-- WrapIt::Container(#{item.object_id.to_s(16)}) -->")
        else
          item
        end
      end
    end
  end
end
