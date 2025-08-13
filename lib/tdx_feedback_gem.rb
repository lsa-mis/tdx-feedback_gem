# frozen_string_literal: true

require_relative 'tdx_feedback_gem/version'
require_relative 'tdx_feedback_gem/configuration'

require_relative 'tdx_feedback_gem/engine' if defined?(Rails)

module TdxFeedbackGem
  class Error < StandardError; end
  # Your code goes here...
end
