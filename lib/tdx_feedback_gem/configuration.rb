# frozen_string_literal: true

module TdxFeedbackGem
  class Configuration
    attr_accessor :require_authentication

    def initialize
      @require_authentication = false
    end
  end

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield(config)
    end
  end
end
