# frozen_string_literal: true

module TdxFeedbackGem
  class Configuration
    attr_accessor :require_authentication

    # TDX API base URL, OAuth credentials, and scope
    attr_accessor :tdx_base_url, :oauth_token_url, :client_id, :client_secret, :oauth_scope

    # Ticket creation toggles and defaults
    attr_accessor :enable_ticket_creation, :app_id, :type_id, :status_id, :source_id,
                  :service_id, :responsible_group_id, :title_prefix, :default_requestor_email

    def initialize
      @require_authentication = false

      # Defaults (host app should override via initializer or ENV)
      @tdx_base_url = nil # e.g., https://gw-test.api.it.umich.edu/um/it
      @oauth_token_url = nil # e.g., https://gw-test.api.it.umich.edu/um/it/oauth2/token
      @client_id = nil # e.g., get client_id from credentials file
      @client_secret = nil # e.g., get client_secret from credentials file
      @oauth_scope = 'tdxticket'

      @enable_ticket_creation = false
      @app_id = nil
      @type_id = nil
      @status_id = nil
      @source_id = nil
      @service_id = nil
      @responsible_group_id = nil
      @title_prefix = '[Feedback]'
      @default_requestor_email = nil
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
