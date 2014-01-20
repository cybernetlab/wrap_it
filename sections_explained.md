# wrap_it sections

Sections intended to simplify elements thats include complex html markup. Also it makes capturing process clearly when you have more that one classes in hierarhy. Sections is just an array of strings, containing html with corresponding ordered array of section names. So, you can define some sections in base class and some in its descendant. Then you can place its respecting each other in any level of hierarchy without changes in other classes. And after that all classes in capture callbacks puts html markup into sections. Finally, all sections joined in specific order and gives result of rendering.

`WrapIt::Base` class defines three sections: `:content`, `:render_arguments`, ``render_block`. Main is `:content`. This section will contain content, captured from template. `render_arguments` and `render_block` sections contains content, retrieved from arguments and blocl, specified in `render` method call. `WrapIt::TextContainer` module adds `:body` section that contains first text argument, specified with helper call, or `:text` or `:body` option. `WrapIt::Container` adds `:children` section that contains all rendered children items.

For example, lets look on [Twitter Bootstrap input groups](http://getbootstrap.com/components/#input-groups-basic):

```html
<div class="input-group">
  <span class="input-group-addon">@</span>
  <input type="text" class="form-control" placeholder="Username">
</div>

<div class="input-group">
  <input type="text" class="form-control">
  <span class="input-group-addon">.00</span>
</div>

<div class="input-group">
  <span class="input-group-addon">$</span>
  <input type="text" class="form-control">
  <span class="input-group-addon">.00</span>
</div>
```

We have main element `input`, wrapped into `div`, and optionally appended or prepended with `span` elements. So, lets code:

```ruby
module BS
  class InputGroup < WrapIt::Base
    section :append, :prepend
    place :prepend, before: :content
    place :append, after: :content
 
    after_initialize do
      @prepend = options.delete(:prepend)
      @append = options.delete(:append)
    end
 
    after_capture do
      unless @prepend.nil?
        self[:prepend] = content_tag('span', @prepend,
                                     class: 'input-group-addon')
      end
      unless @append.nil?
        self[:append] = content_tag('span', @append,
                                    class: 'input-group-addon')
      end
      if self[:content].empty?
        # inject type and class into user-defined options
        options[:type] = 'text'
        add_html_class 'form-control'
        self[:content] = content_tag('input', '', options)
        # pass to wrapper div only 'input-group' class
        options.clear
        add_html_class 'input-group'
      end
    end
```

Now to render above html we can use it as follows:

```html
<%= input_group prepend: '@', placeholder: 'Username' %>
<%= input_group append: '.00' %>
<%= input_group append: '.00', prepend: '$' %>
```

Have a fun!
