source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.5'
gem 'rails-i18n'
gem 'unicorn' # Dev server
gem 'rack-cors', :require => 'rack/cors' # For Cross Domain JSON
gem 'activesupport-json_encoder', github: 'rails/activesupport-json_encoder' # JSON encoding library
gem 'aws-sdk' # Amazon S3 SDK
gem 'paperclip' # Easy S3 uploader
gem 'paypal-sdk-rest' # For Paypal OAuth2
gem "braintree" # For mobile payments
#gem 'rmagick' # Image Resizer

gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass', '3.2.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bcrypt' # Supersecure passwords
gem 'wkhtmltopdf' # PDF library
gem 'wicked_pdf' # PDF library+
gem 'twilio-ruby' # SMS
gem 'sepa_king' # XML Payment Initiation (pain)

group :development, :test do
  gem 'rspec-rails'
end

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  gem 'rails_12factor', '0.0.2'
  gem "wkhtmltopdf-heroku"
end