source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.5'
gem 'rails-i18n'
gem 'rack-cors', :require => 'rack/cors' # For Cross Domain JSON

gem 'pg'
gem 'sass-rails', '~> 4.0.3'
gem 'bootstrap-sass', '3.2.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'bcrypt' #Supersecure passwords
gem 'unicorn' #Server
gem 'wkhtmltopdf' #PDF library
gem 'wicked_pdf' #PDF library+
gem 'twilio-ruby' #SMS
gem 'paypal-sdk-rest' #Paypal receive money
gem 'paypal-sdk-adaptivepayments' #Paypal send money
gem 'sepa_king' #XML Payment Initiation (pain)

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