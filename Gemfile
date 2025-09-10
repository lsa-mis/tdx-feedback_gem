# frozen_string_literal: true

source 'https://rubygems.org'

# Use the gemspec to manage dependencies for development and testing
gemspec

group :development, :test do
  gem 'capybara', '~> 3.40'
  gem 'rspec', '~> 3.13'
  gem 'rspec-rails', '~> 6.0'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'sqlite3', '~> 1.4'
  gem 'webmock', '~> 3.18'
  # Provide Importmap support so we can test auto-pin initializer behavior
  gem 'importmap-rails', '~> 2.0'
end
