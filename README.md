[![Gem Version](https://badge.fury.io/rb/wrap_it.png)](http://badge.fury.io/rb/wrap_it)
[![Code Climate](https://codeclimate.com/github/cybernetlab/wrap_it.png)](https://codeclimate.com/github/cybernetlab/wrap_it)
[![Build Status](https://travis-ci.org/cybernetlab/wrap_it.png?branch=master)](https://travis-ci.org/cybernetlab/wrap_it)

# WrapIt

This library provides set of classes and modules with simple DSL for quick and easy creating html helpers with your own DSL. It's usefull for implementing CSS frameworks, or making your own.

> Required ruby version is 2.0.0

> **Warning** A lot of code refactored. API changed. Review you code if you using previous versions of library.

For example, your designer makes perfect button style for some site. This element will appears in many places of site in some variations. The button have `danger`, `success` and `default` look, and can have `active` state. Button can have some icon. So, you make some CSS styles, and now you should place HTML markup of this element in many places of site. With `wrap_it` library you can do it with following code:

```ruby
module Helpers; end

WrapIt.register_module Helpers

module Helpers
  class PerfectButton < WrapIt::Container
    include TextContainer
    html_class 'button'
    enum :look, %i(default success danger), html_class_prefix: 'button-'
    switch :active, html_class: 'button-active'
    child :icon, tag: 'img', class: 'button-icon'
  end

  register :p_button, 'PerfectButton'
end
```

Now, include this helper into you template engine. For Rails:

```ruby
class MyController < ApplicationController
  helper Helpers
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

This is a first release version - `1.0.0`.

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

Now, package is well documented, so make sure to inspect [Reference documentation](http://rubydoc.info/github/cybernetlab/wrap_it/frames)

> This library actively used in [BootstrapIt](https://github.com/cybernetlab/bootstrap_it) package, so explore this project, especially it's [lib/bootstrap_it/view_helpers](https://github.com/cybernetlab/bootstrap_it/tree/master/lib/bootstrap_it/view_helpers) folder for usage examples.

All helpers classes derived from `WrapIt::Base` class, that provides allmost all functionality. For helpers, thats includes other helpers, use `WrapIt::Container` class.

Simple example explained above. More complex usage is to provide some logic to initalization, capturing and rendering process. To do this, use `after` or `before` `initialize`, `capture` and `reder` callbacks respectively. Usually `after` callbacks used. `initialize` callbacks runs around arguments and optioins parsing, `capture` callbacks runs around capturing element sections and `render` callbacks runs around wrapping content into element tag.

Also, please inspect arguments [module documentation](http://rubydoc.info/github/cybernetlab/wrap_it/WrapIt/Arguments) for details about creation arguments and options.

Inside callbacks some usefull instance variables available.

`tag` contains tag name for element.

`html_attr` contains HTML attributes hash.

`html_data` contains HTML data hash.

`html_class` contains array of HTML classes and provides array-like acces to its. See [class documentation](http://rubydoc.info/github/cybernetlab/wrap_it/WrapIt/HTMLClass) for details.

Inside `capture` callback you deals with sections. This mechanism explained in [module documentation](http://rubydoc.info/github/cybernetlab/wrap_it/WrapIt/Sections).

`template` contains rendering template. Use this variable carefully, so if you call `template.link_to` or something else Rails-related, your library will not be portable to other frameworks. So, if you use this gem in user-end application, or Rails-only library, you are free to use all of `template` methods.

*Examples*

Prevent user from changing element tag:

```ruby
class Helper < WrapIt::Base
  after_initialize { self.tag = 'table' }
end
```

Including some simple HTML into content

```ruby
class IconHelper < WrapIt::Base
  option :icon
  attr_accessor :icon

  after_capture do
    unless @icon.nil?
      self[:content] = html_safe("<i class=\"#{@icon}\"></i>")
    end
  end
```

## WrapIt

#### WrapIt.register_module(*args)

Registers helpers module and defines `register` and `unregister` class methods in this module for registering helper methods. You can specify module to register in first argument. If ommited, anonymous module will be created and returned from method. Use `prefix` option to add specified prefix to all methods in helper module.

Typical usage of library and this method is:

Define empty module and register it with `register_method`:

```ruby
module YourPerfectLib
  module PerfectHelpers; end

  WrapIt.register_module PerfectHelpers, prefix: 'perfect_'

  # You can register all your helper methods right here, but in complex
  # projects recommended to keep calls to register inside file where
  # helper class defined.
  #
  # PerfectHelpers.register :button, 'YourPerfectLib::PerfectHelpers::Button'
end
```

Describe your classes and register helper methods for it:

```ruby
module YourPerfectLib
  module PerfectHelpers
    class Button < WrapIt::Base
      include WrapIt::TextContainer
      html_class 'button'
 
      ...
    end
  end

  register :button, 'YourPerfectLib::PerfectHelpers::Button'
end
```

Include it in your template (example for Rails):

```ruby
class MyController < ApplicationController
  helper Helpers
  ...
end
```

And now use it in templates:

```html
<%= perfect_button 'button text' %>
```

will produce:

```html
<div class="button">button text</button>
```

## WrapIt::Base

### DSL methods

#### default_tag(name)

Use `default_tag` DSL method inside your class to specify HTML tag name for element. This tag can be changed soon by you or user. `name` can be `Symbol` or `String` and it converted to `String`.

#### html_class(*args)

Use `html_class` DSL method to add default html classes, thats are automatically added when element created.

#### html_class_prefix(prefix)

Sets html class prefix. It can be `Symbol` or `String` and converted to `String`. This value used with `switch` and `enum` functionality. See its descriptions below.

#### omit_content

Once this method called from class, this class will ommit any text content, captured from template. For example, `<%= element do %><p>Any content</p><% end %>` normally will produce `<div><p>Any content</p></div>`. In some cases you whant to drop `<p>Any content</p>`, for exmaple, inside tables.

#### argument(name, first_only: false, after_options: false, **opts, &block)

Desclares argument for capturing on initialization process.

Inside initialization process, all arguments (except options hash), passed to constructor will be inspected to satisfy conditions, specified in `:if` and `:and` options. If this happens, and block given, it evaluated in context of component instance. If no block given, setter with `name` will be attempted to set value. In any way if conditions satisfied, argument removed from future processing.

If no conditions specified, the `name` of attribute taked as only condition.

#### option(name, after: nil, **opts, &block)

Desclares option for capturing on initialization process.

Provides same manner as `argument` but for hash of options, passed to constructor. Specified conditions are applied to options keys, not to values.

> Hint: you can specify argument and options with same name to call
> same setter.


#### switch(name, options = {}, &block)

Adds `switch`. Switch is a boolean flag. When element created, creation arguments will be scanned for `Symbol`, that equals to `name`. If it founded, switch turned on. Also creation options inspected. If its contains `name: true` key-value pair, this pair removed from options and switch also turned on. `name` can be `Symbol` or `String` and it converted to `Symbol`.

This method also adds getter and setter for this switch in form `name?` and `name=` respectively.

When `html_class` option specified and switch changes its state, HTML class for element will be computed as follows. if `html_class` options is `true`, html class produced from `html_class_prefix` and `name` of switch. If `html_class` is a String, Symbol or Array of this types, html class produced as array of `html_class_prefix` and each `html_class` concatinations. This classes added to element if switch is on or removed in other case.
      
Also `aliases` option available. So if some of aliases founded in arguments it also changes switch state. You should pass only `Symbol` or `Array` if symbols to this optioin.

If block given, it will be called each time switch changes its state in context of element with the switch state as argument. If you return `false`  from this block, value is ommited.

#### enum(name, options = {}, &block)

Adds `enum`. When element created, creation arguments will be scanned for `Symbol`, that included contains in `values`. If it founded, enum takes this value. Also creation options inspected. If its  contains `name: value` key-value pair with valid value, this pair removed from options and enum takes this value.

This method also adds getter and setter for this enum.

If you set `html_class` option to `true`, with each enum change, HTML class, composed from `html_class_prefix` and enum `value` will be added to element. If you want to override this prefix, specify it with `html_class_prefix` option. By default, enum changes are not affected to html classes.

Also `aliases` option available. So if some of aliases founded in creation options keys it also changes enum value. You should pass only `Symbol` or `Array` if symbols to this optioin.

`default` option sets default value for enum. This value will used if nil or invalid value assigned to enum.

If block given, it will be called each time enum changes its value in context of element with the new value as argument.

#### section(*args)

Adds one ore more sections to element. Refer to [Sections explained](https://github.com/cybernetlab/wrap_it/blob/master/sections_explained.md) article for description.

#### place(src, dst)

Places section `src` to destination, specified in `dst` hash. `dst` is a single key-value Hash. Key can be `:before` and `:after`. Value can be `:begin`, `:end` or any section name.

#### sections

Returns list of all sections, including derived from parent classes.

#### placement

Returns placed sections.

### Instance methods

#### self[name] and self[name]=

Retrieves or sets `name` section. Refer to [Sections explained](https://github.com/cybernetlab/wrap_it/blob/master/sections_explained.md) article for description.

#### wrap(*args, &block)

Wraps element with another.

You can provide wrapper directly or specify wrapper class as first argument. In this case wrapper will created with specified set of arguments and options. If wrapper class ommited, WrapIt::Base will be used.

If block present, it will be called when wrapper will rendered.

#### html_class

Returns array of html classes

#### html_class=(*args)

Sets html class(es) for element. Arguments can be `String`, `Symbol` or `Array` of it. All converted to plain array of `Symbols`. Duplicated classes removed.

#### html_class << *args

You can add html classes as into array

#### html_class.include?(*args, &block)

Determines whether element contains class, satisfied by conditions, specified in method arguments.

There are two forms of method call: with list of conditions as arguments and with block for comparing. Method makes comparison with html class untill first `true` return value or end of list. All conditions should be satisfied for `true` return of this method.

In first form, each argument treated as condition. Condition can be a `Regexp`, so html classes of element tested for matching to that regular expression. If condition is an `Array` then every class will be tested for presence in this array. If condition is `Symbol` or `String` classes will be compared with it via equality operator `==`.

In second form all arguments are ignored and for each comparison given block called with html class as argument. Block return value then used.

*Examples*

```ruby
# with `Symbol` or `String` conditions
element.html_class = [:a, :b, :c]
element.html_class.include?(:a)       #=> true
element.html_class.include?(:d)       #=> false
element.html_class.include?(:a, 'b')  #=> true
element.html_class.include?(:a, :d)   #=> false

# with `Regexp` conditions
element.html_class = [:some, :test]
element.html_class.include?(/some/)         #=> true
element.html_class.include?(/some/, /bad/)  #=> false
element.html_class.include?(/some/, :test)  #=> true

# with `Array` conditions
element.html_class = [:a, :b, :c]
element.html_class.include?(%w(a d)) #=> true
element.html_class.include?(%w(e d)) #=> false

# with block
element.html_class = [:a, :b, :c]
element.html_class.include? { |x| x == 'a' } #=> true
```


Look to [Reference documentation](http://rubydoc.info/github/cybernetlab/wrap_it/frames) for other classes description.

# Todo

* Enlarge library functionality
* Finish Sinatra integration

# Changes

`1.0.0`
* first release version
* a lot of code refactored
* documentation allmost finished
* well test coverage
* API changed
* added: arguments and options processing

`0.2.0`
* added: sections mechanism
* many fixes
* testing improvement
* preparing testing for multiple frameworks

`0.1.5`
* fixed: switches and enums can damage instance variables
* fixed: process helper_name option before initialize callbacks
* fixed: convert user defined tag to string
* added: Link class

`0.1.4`
* added: html_class_prefix

`0.1.3`
* this is a fix for 0.1.2, that it was not properly compiled.

`0.1.2`
* fixed: double callbacks inclusion issue
* added: Base#wrap
* added: HTML data attribute processing
* test improvements

`0.1.1`
* WrapIt.helpers fails if no helper registered

`0.1.0`
* initial version

# Testing

This package developed for different frameworks, so testing is not so simple. At first, prepare testing environment with:

```sh
bundle install
bundle install --gemfile Gemfile.rails4
bundle install --gemfile Gemfile.sinatra
```

And then you can run tests as follows:

```sh
FRAMEWORK=rails4 bundle exec rake spec
FRAMEWORK=sinatra bundle exec rake spec
```

As sinatra support is in progress, its test will not pass yet.

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
