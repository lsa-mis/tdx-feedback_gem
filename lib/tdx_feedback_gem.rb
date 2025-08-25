# frozen_string_literal: true

require_relative 'tdx_feedback_gem/version'
require_relative 'tdx_feedback_gem/configuration'
require_relative 'tdx_feedback_gem/client'
require_relative 'tdx_feedback_gem/ticket_creator'

require_relative 'tdx_feedback_gem/engine' if defined?(Rails)

module TdxFeedbackGem
  class Error < StandardError; end
  # Your code goes here...
end

TdxFeedbackGem.configure do |config|
  # OAuth secrets (host app owns them)
  config.client_id     = Rails.application.credentials.dig(:tdx, :client_id) || ENV['TDX_CLIENT_ID']
  config.client_secret = Rails.application.credentials.dig(:tdx, :client_secret) || ENV['TDX_CLIENT_SECRET']

  # URLs, also via credentials or ENV
  config.tdx_base_url    = Rails.application.credentials.dig(:tdx, :base_url)    || ENV['TDX_BASE_URL']
  config.oauth_token_url = Rails.application.credentials.dig(:tdx, :token_url)   || ENV['TDX_TOKEN_URL']

  # ...other IDs and options...
end
