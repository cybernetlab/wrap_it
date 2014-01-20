require 'rubygems'
require 'bundler'

Bundler.require :default, :development

if /sinatra/ =~ ENV['FRAMEWORK']
  require File.join(File.dirname(__FILE__), 'frameworks', 'sinatra_app.rb')
  FRAMEWORK = :sinatra
elsif /rails/ =~ ENV['FRAMEWORK']
  require File.join(File.dirname(__FILE__), 'frameworks', 'rails_app.rb')
  FRAMEWORK = :rails
end

Dir[File.join(File.dirname(__FILE__), 'support', '**', '*.rb')].each do |file|
  require file
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
