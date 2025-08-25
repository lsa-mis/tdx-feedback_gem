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
require 'webmock/rspec'

# Explicitly require model since Rails autoloading isn't active in specs
require File.expand_path('../app/models/tdx_feedback_gem/feedback', __dir__)

# Shared contexts for common test scenarios
RSpec.shared_context 'with authenticated user' do
  before do
    allow(controller).to receive(:current_user).and_return(double('user', email: 'test@example.com'))
  end
end

RSpec.shared_context 'with TDX configuration' do
  before do
    TdxFeedbackGem.configure do |c|
      c.enable_ticket_creation = true
      c.app_id = 31
      c.type_id = 12
      c.status_id = 77
      c.source_id = 8
      c.service_id = 67
      c.responsible_group_id = 631
      c.title_prefix = '[Feedback]'
      c.default_requestor_email = 'noreply@example.com'
      c.tdx_base_url = 'https://example.test'
      c.oauth_token_url = 'https://example.test/oauth/token'
      c.client_id = 'id'
      c.client_secret = 'secret'
    end
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Include FactoryBot-like helpers for creating test data
  config.include FactoryBot::Syntax::Methods if defined?(FactoryBot)

  # Clean up database between tests
  config.before(:each) do
    TdxFeedbackGem::Feedback.delete_all
  end

  # Reset configuration between tests by reconfiguring with defaults
  config.after(:each) do
    TdxFeedbackGem.configure do |c|
      c.require_authentication = false
      c.enable_ticket_creation = false
      c.tdx_base_url = nil
      c.oauth_token_url = nil
      c.client_id = nil
      c.client_secret = nil
      c.oauth_scope = 'tdxticket'
      c.app_id = nil
      c.type_id = nil
      c.status_id = nil
      c.source_id = nil
      c.service_id = nil
      c.responsible_group_id = nil
      c.title_prefix = '[Feedback]'
      c.default_requestor_email = nil
    end
  end

  # Include shared contexts only for controller and request specs
  config.include_context 'with authenticated user', type: :controller
  config.include_context 'with TDX configuration', type: :request
end
