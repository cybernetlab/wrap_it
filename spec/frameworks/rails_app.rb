# require 'rails'
# require 'action_controller/railtie'

# require 'sprockets/railtie'

require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_view/base'
require 'action_controller/base'

#
# Simple Rails application for testing
#
#
module RailsApp
  #
  # App class
  #
  class Application < Rails::Application
    config.secret_token =
      '572c86f5ede338bd8aba8dae0fd3a326aabababc98d1e6ce34b9f0'

#    config.session_store :cookie_store, key: '_myproject_session'
    config.active_support.deprecation = :stderr
    config.root = File.dirname(__FILE__)
#    config.root = File.join __FILE__, '..'
    Rails.backtrace_cleaner.remove_silencers!
    config.cache_store = :memory_store
    config.consider_all_requests_local = true
    config.eager_load = false

    config.assets.enabled = false
#    config.assets.enabled = true if ::Rails::VERSION::MAJOR < 4
#    config.assets.cache_store =
#      [:file_store, "#{config.root}/tmp/cache/assets/"]

    routes.draw do
      get  '/test' => 'rails_app/tests#index'
    end
  end

  #
  # Main controller
  #
#  class TestsController < ActionController::Base
#    helper WrapIt.helpers

#    def index
#      render inline: @code
#    end
#  end
end

# configure rails application
RailsApp::Application.configure do |app|
#  app.middleware.use MyRackMiddleware
end

RailsApp::Application.initialize!

defined?(Capybara) && Capybara.app = RailsApp::Application
