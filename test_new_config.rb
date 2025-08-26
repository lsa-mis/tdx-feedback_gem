#!/usr/bin/env ruby

# Simple test script to verify the new URL resolution functionality

# Load the gem
$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'tdx_feedback_gem/configuration'

puts "Testing new URL resolution functionality..."
puts

# Test 1: Default behavior (no Rails, no ENV)
puts "Test 1: Default behavior (no Rails, no ENV)"
config = TdxFeedbackGem::Configuration.new
puts "  tdx_base_url: #{config.tdx_base_url}"
puts "  oauth_token_url: #{config.oauth_token_url}"
puts

# Test 2: With ENV variables
puts "Test 2: With ENV variables"
ENV['TDX_BASE_URL'] = 'https://env.api.example.com/um/it'
ENV['TDX_OAUTH_TOKEN_URL'] = 'https://env.api.example.com/um/oauth2/token'
config = TdxFeedbackGem::Configuration.new
puts "  tdx_base_url: #{config.tdx_base_url}"
puts "  oauth_token_url: #{config.oauth_token_url}"
puts

# Test 3: Mock Rails production environment
puts "Test 3: Mock Rails production environment"
ENV.delete('TDX_BASE_URL')
ENV.delete('TDX_OAUTH_TOKEN_URL')

# Mock Rails for production
module Rails
  def self.env
    ActiveSupport::StringInquirer.new('production')
  end

  def self.application
    nil
  end
end

config = TdxFeedbackGem::Configuration.new
puts "  tdx_base_url: #{config.tdx_base_url}"
puts "  oauth_token_url: #{config.oauth_token_url}"
puts

# Test 4: Mock Rails development environment
puts "Test 4: Mock Rails development environment"

# Mock Rails for development
module Rails
  def self.env
    ActiveSupport::StringInquirer.new('development')
  end

  def self.application
    nil
  end
end

config = TdxFeedbackGem::Configuration.new
puts "  tdx_base_url: #{config.tdx_base_url}"
puts "  oauth_token_url: #{config.oauth_token_url}"
puts

puts "All tests completed successfully!"
