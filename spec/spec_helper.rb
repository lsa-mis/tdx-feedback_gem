# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

# Minimal ActiveRecord setup for model tests
require 'active_record'
require 'action_controller/railtie'
require 'action_dispatch/railtie'
require 'logger'

ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# Define the schema used in tests
ActiveRecord::Schema.define do
  create_table :tdx_feedback_gem_feedbacks, force: true do |t|
    t.text :message, null: false
    t.text :context
    t.timestamps
  end
end

require 'tdx_feedback_gem/configuration'
require 'tdx_feedback_gem/version'

# Minimal Rails app for request specs
class DummyApp < Rails::Application
  config.secret_key_base = 'test'
  config.eager_load = false
  config.root = File.expand_path('dummy', __dir__)
  config.hosts.clear
end

ENV['RAILS_ENV'] ||= 'test'
require 'tdx_feedback_gem' # Load gem after Rails is defined so Engine is loaded
Rails.application.initialize!
load File.expand_path('dummy/config/routes.rb', __dir__)

require 'rspec/rails'

# Explicitly require model since Rails autoloading isn't active in specs
require File.expand_path('../app/models/tdx_feedback_gem/feedback', __dir__)

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
