source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.1'
# Use sqlite3 as the database for Active Record
#gem 'sqlite3'

gem 'bootstrap-sass', '~> 3.3.4'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Use Devise for user auth
gem 'devise'

# Use pg for the database
gem 'pg'

# Use kaminari for pagination
gem 'kaminari'

# Use pundit for authorization
gem 'pundit'

# Use redcarpet for markdown formatting
gem 'redcarpet'

# Use sanitize for HTML sanitization
gem 'sanitize', '~> 4.0.0'

gem 'pry-rails'
gem 'pry-doc'

# Use ActiveAdmin for the admin panel
gem 'activeadmin', '~> 1.0.0pre1'

# used by ActiveAdmin
gem 'country_select', github: 'stefanpenner/country_select'

# Use figaro for app configuration
gem 'figaro'

# Use paper_trail for logging actions
gem 'paper_trail', '~> 4.0.0'

group :development do
  # Use faker for creating seed data
  gem 'faker'
  # Required for rails_panel
  gem 'meta_request'

  gem 'better_errors'
  # Required for some features of better_errors
  gem 'binding_of_caller'
end

group :test do
  # Required for Travis CI tests
  gem 'rake'

  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'factory_girl_rails'
end