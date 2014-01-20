require 'wrap_it/frameworks'

if WrapIt.rails?
  require 'rails'
  require 'wrap_it/rails'
else
  require 'wrap_it/no_rails'
end

require 'wrap_it/helpers'

require 'wrap_it/derived_attributes'
require 'wrap_it/callbacks'
require 'wrap_it/sections'
require 'wrap_it/arguments_array'
require 'wrap_it/html_class'
require 'wrap_it/html_data'
require 'wrap_it/switches'
require 'wrap_it/enums'
require 'wrap_it/base'
require 'wrap_it/container'
require 'wrap_it/text_container'
require 'wrap_it/link'
