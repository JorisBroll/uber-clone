require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Naveco
  class Application < Rails::Application
	I18n.default_locale = :fr
	I18n.locale = :fr
	config.i18n.default_locale = :fr
	config.i18n.locale = :fr
  end
end
