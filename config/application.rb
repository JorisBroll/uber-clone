require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Naveco
  class Application < Rails::Application
  	config.i18n.enforce_available_locales = true
  	config.assets.precompile += %w( application )

  	config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end
    
	#config.i18n.default_locale = :fr
	#config.i18n.locale = :fr
  end
end