if RUBY_VERSION >= '2.1.0'
  require 'ensure_it_refined'
else
  require 'ensure_it'
end

EnsureIt.configure do |config|
  config.error_class = ArgumentError
end

require File.join %w(wrap_it frameworks)

if WrapIt.rails?
  require 'rails'
  require File.join %w(wrap_it rails)
else
  require File.join %w(wrap_it no_rails)
end

require File.join %w(wrap_it helpers)

require File.join %w(wrap_it derived_attributes)
require File.join %w(wrap_it callbacks)
require File.join %w(wrap_it capture_array)
require File.join %w(wrap_it arguments)
require File.join %w(wrap_it sections)
require File.join %w(wrap_it html)
require File.join %w(wrap_it switches)
require File.join %w(wrap_it enums)
require File.join %w(wrap_it base)
require File.join %w(wrap_it container)
require File.join %w(wrap_it text_container)
require File.join %w(wrap_it link)
