source 'http://rubygems.org'

gem 'rack' , '1.3.3'
rails_version = '~> 3.1.0'
gem 'rails', rails_version
gem 'andand'
gem 'capistrano'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   rails_version
  gem 'coffee-rails', rails_version
  gem 'uglifier'
end

gem 'jquery-rails'

# Use unicorn as the web server
gem 'unicorn'

group :development do
  gem 'heroku'
  gem 'looksee', :require => false
  gem 'wirb'
  gem 'ruby-debug19', :require => 'ruby-debug'
  # gem 'pry'
  # gem 'pry-doc'
  gem 'rails-footnotes', '>= 3.7'
end

group :test, :development do
  gem "rspec-rails", "~> 2.6"
  gem "factory_girl_rails"
end

gem 'uuidtools'
gem 'redis'
gem "mongoid", "~> 2.2.0"
gem "bson_ext", "~> 1.3"
gem 'url'
gem 'typed-matcher'
gem 'redis-store'
gem "resque", "~> 1.19.0"
