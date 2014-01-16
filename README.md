# WrapIt

This library provides set of classes and modules with simple DSL for quick and easy creating html helpers with your own DSL. It's usefull for implementing CSS frameworks, or making your own.

For example, your designer makes perfect button style for some site. This element will appears in many places of site in some variations. The button have `danger`, `success` and `default` look, and can have `active` state. Button can have some icon. So, you make some CSS styles, and now you should place HTML markup of this element in many places of site. With `wrap_it` library you can do it with following code:

```ruby
class PerfectButton < WrapIt::Container
  include TextContainer
  html_class 'button'
  enum :look, [:default, :success, :danger], html_class_prefix: 'button-'
  switch :active, html_class: 'button-active'
  child :icon, [tag: 'img', class: 'button-icon']
end

WrapIt.register :p_button, 'PerfectButton'
```

Now, include this helper into you template engine. For Rails:

```ruby
class MyController < ApplicationController
  helper WrapIt.helpers
  ...
end
```

And you can use it in you ERB:

```html
<%= p_button %>button 1<% end %>
<%= p_button 'button 2', :active, :success %>
<%= p_button active: true, look: :success, body: 'button 3' %>
<%= p_button :danger do |b| %>
  <%= b.icon src: '/path/to/icon.png' %>
  button 4
<% end %>
```

This will produce following code:

```html
<div class="button">button 1</div>
<div class="button button-active button-success">button 2</div>
<div class="button button-active button-success">button 3</div>
<div class="button button-danger">
  <img class="button-icon" src="/path/to/icon.png">
  button 4
</div>
```

Note, that lines 2 and 3 produces same html markup.

# Status

Project in pre-release state. First release version `1.0.0` planned to February of 2014.

# Installation

Library have a gem. So, just install it:

```sh
gem install wrap_it
```

or include in your `Gemfile`

```ruby
gem 'wrap_it'
```

and run

```sh
bundle install
```

# Configuration

Library have no specific configuration.

# Usage

All helpers classes derived from `WrapIt::Base` class, that provides allmost all functionality. For helpers, thats includes other helpers, use `WrapIt::Container` class. Where are some library-specific methods, defined directly in `WrapIt` module.

Simple example explained above. More complex usage is to provide some logic to initalization, capturing and rendering process. To do this, use `after` or `before` `initialize`, `capture` and `reder` callbacks respectively. Usually `after` callbacks used. `initialize` callbacks runs around arguments and optioins parsed, `capture` callbacks runs around capturing content of element and `render` callbacks runs around wrapping content into element tag.

Inside callbacks some usefull instance variables available.

`@tag` contains tag name for element.

`@options` contains creation options hash. This hash also contains `:class` key with current set of HTML classes. But its recommended to use class-aware methods to manipulate html classes (see below). **Warning!** You **MUST** remove from this hash all your class-specific user options, because this hash will be used as list of HTML attributes of element.

`@arguments` array available only in `after_initialize` callback and contains creation arguments. Its recommended to extract arguments, related to your class from this array if you plan to subclass your helper in future, so when subclasses `after_initialize` called these arguments will not available there.

`@content` string available in `capture` and `render` callbacks and contains captured content. You can change it to any value. If you want to render some html markup with `@content`, use `html_safe` method (see below) to prevent HTML escaping.

`@template` contains rendering template. Use this variable carefully, so if you call `@template.content_tag` or something else Rails-related, your library will not be portable to other frameworks. So, if you use this gem in user-end application, or Rails-only library, you are free to use all of `@template` methods.

*Examples*

Prevent user from changing element tag:

```ruby
class Helper < WrapIt::Base
  after_initialize { @tag = 'table' }
end
```

Including some simple HTML into content

```ruby
class Helper < WrapIt::Base
  after_initialize do
    @icon = optioins.delete(:icon)
  end

  after_capture do
    unless @icon.nil?
      @content = html_safe("<i class=\"#{@icon}\"></i>") + @content
    end
  end
```

## WrapIt

#### WrapIt.register(*args)

Registers helper class. In arguments, first specify helper method names as `Symbols` and in last argument fully qualified helper class name as `String`.

#### WrapIt.unregister(*args)

Unregisters helper class. Just pass list of method names as `Symbols`.

#### WrapIt.helpers

Returns a module, that contains all registered helpers. Usefull to provide all helpers to template engine.

## WrapIt::Base

### DSL methods

#### default_tag(name)

Use `default_tag` DSL method inside your class to specify HTML tag name for element. This tag can be changed soon by you or user. `name` can be `Symbol` or `String` and it converted to `String`.

#### html_class(*args)

Use `html_class` DSL method to add default html classes, thats are automatically added when element created.

#### omit_content

Once this method called from class, this class will ommit any text content, captured from template. For example, `<%= element do %><p>Any content</p><% end %>` normally will produce `<div><p>Any content</p></div>`. In some cases you whant to drop `<p>Any content</p>`, for exmaple, inside tables.

#### switch(name, options = {}, &block)

Adds `switch`. Switch is a boolean flag. When element created, creation arguments will be scanned for `Symbol`, that equals to `name`. If it founded, switch turned on. Also creation options inspected. If its contains `name: true` key-value pair, this pair removed from options and switch also turned on. `name` can be `Symbol` or `String` and it converted to `Symbol`.

This method also adds getter and setter for this switch in form `name?` and `name=` respectively.

You can pass `html_class` option. If it presend, this class will be added or removed to element when switch changes its state.

Also `aliases` option available. So if some of aliases founded in arguments it also changes switch state. You should pass only `Symbol` or `Array` if symbols to this optioin.

If block given, it will be called each time switch changes its state in context of element with the switch state as argument.

#### enum(name, options = {}, &block)

Adds `enum`. When element created, creation arguments will be scanned for `Symbol`, that included contains in `values`. If it founded, enum takes this value. Also creation options inspected. If its  contains `name: value` key-value pair with valid value, this pair removed from options and enum takes this value.

This method also adds getter and setter for this enum.

You can pass `html_class_prefix` option. If it present, HTML class will be combined from it and enum value and added or removed from element HTML class.

Also `aliases` option available. So if some of aliases founded in creation options keys it also changes enum value. You should pass only `Symbol` or `Array` if symbols to this optioin.

`default` option sets default value for enum. This value will used if nil or invalid value assigned to enum.

If block given, it will be called each time enum changes its value in context of element with the new value as argument.

### Instance methods

#### html_class

Returns array of html classes

#### html_class=(*args)

Sets html class(es) for element. Arguments can be `String`, `Symbol` or `Array` of it. All converted to plain array of `Symbols`. Duplicated classes removed.

#### add_html_class(*args)

Adds html class. For args see `#html_class=`

#### remove_html_class(*args)

Removes html class. For args see `#html_class=`

#### html_class?(*args, &block)

Determines whether element contains class, satisfied by conditions, specified in method arguments.

There are two forms of method call: with list of conditions as arguments and with block for comparing. Method makes comparison with html class untill first `true` return value or end of list. All conditions should be satisfied for `true` return of this method.

In first form, each argument treated as condition. Condition can be a `Regexp`, so html classes of element tested for matching to that regular expression. If condition is an `Array` then every class will be tested for presence in this array. If condition is `Symbol` or `String` classes will be compared with it via equality operator `==`.

In second form all arguments are ignored and for each comparison given block called with html class as argument. Block return value then used.

*Examples*

```ruby
# with `Symbol` or `String` conditions
element.html_class = [:a, :b, :c]
element.html_class?(:a)       #=> true
element.html_class?(:d)       #=> false
element.html_class?(:a, 'b')  #=> true
element.html_class?(:a, :d)   #=> false

# with `Regexp` conditions
element.html_class = [:some, :test]
element.html_class?(/some/)         #=> true
element.html_class?(/some/, /bad/)  #=> false
element.html_class?(/some/, :test)  #=> true

# with `Array` conditions
element.html_class = [:a, :b, :c]
element.html_class?(%w(a d)) #=> true
element.html_class?(%w(e d)) #=> false

# with block
element.html_class = [:a, :b, :c]
element.html_class? { |x| x == 'a' } #=> true
```

#### no_html_class?(*args, &block)

Determines whether element doesn't contains class, satisfied by conditions, specified in method arguments. See `html_class?`.

## WrapIt::Container

### DSL methods

#### child(*args, &block)

Creates your own DSL method to create child items. In arguments, you should specify list of method names (aliases if more that one). Then you can specify class name for shild. If ommited, `WrapIt::Base` will be used. and as last argument you can specify array of arguments, that will be passed to child constructor. This array will be mixed with arguments, specified by user, with higher priority. At last, you can define block, that will be called after creating child, but before its rendering. This child passed as argument to block.

# Todo

* Enlarge library functionality
* Strong testing
* Finish Sinatra integration
* Rubydoc documentation

# License

The MIT License (MIT)

Copyright (c) 2014 Alexey Ovchinnikov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

