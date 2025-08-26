# frozen_string_literal: true

module TdxFeedbackGem
  class Configuration
    attr_accessor :require_authentication

    # TDX API base URL, OAuth credentials, and scope
    attr_accessor :tdx_base_url, :oauth_token_url, :client_id, :client_secret, :oauth_scope

    # Ticket creation toggles and defaults
    attr_accessor :enable_ticket_creation, :app_id, :type_id, :form_id, :service_offering_id,
                  :status_id, :source_id, :service_id, :responsible_group_id, :title_prefix, :default_requestor_email

    def initialize
      @require_authentication = false

      # Resolve URLs from credentials or ENV based on environment
      @tdx_base_url = resolve_tdx_base_url
      @oauth_token_url = resolve_oauth_token_url
      @client_id = resolve_client_id
      @client_secret = resolve_client_secret
      @oauth_scope = 'tdxticket'

      @enable_ticket_creation = false
      @app_id = nil
      @type_id = nil
      @form_id = nil
      @service_offering_id = nil
      @status_id = nil
      @source_id = nil
      @service_id = nil
      @responsible_group_id = nil
      @title_prefix = '[Feedback]'
      @default_requestor_email = nil
    end

    private

    def resolve_client_id
      # First check Rails encrypted credentials for environment-specific values
      if defined?(Rails) && Rails.application&.credentials
        # Try environment-specific credentials first
        env_key = environment_key
        if env_key
          credential_value = Rails.application.credentials.dig(:tdx, env_key, :client_id)
          return credential_value if credential_value && !credential_value.empty?
        end

        # Fall back to general credential
        credential_value = Rails.application.credentials.tdx_client_id
        return credential_value if credential_value && !credential_value.empty?
      end

      # Fall back to ENV variable
      ENV['TDX_CLIENT_ID']
    end

    def resolve_client_secret
      # First check Rails encrypted credentials for environment-specific values
      if defined?(Rails) && Rails.application&.credentials
        # Try environment-specific credentials first
        env_key = environment_key
        if env_key
          credential_value = Rails.application.credentials.dig(:tdx, env_key, :client_secret)
          return credential_value if credential_value && !credential_value.empty?
        end

        # Fall back to general credential
        credential_value = Rails.application.credentials.tdx_client_secret
        return credential_value if credential_value && !credential_value.empty?
      end

      # Fall back to ENV variable
      ENV['TDX_CLIENT_SECRET']
    end

    def resolve_tdx_base_url
      # First check Rails encrypted credentials for environment-specific values
      if defined?(Rails) && Rails.application&.credentials
        # Try environment-specific credentials first
        env_key = environment_key
        if env_key
          credential_value = Rails.application.credentials.dig(:tdx, env_key, :base_url)
          return credential_value if credential_value && !credential_value.empty?
        end

        # Fall back to general credential
        credential_value = Rails.application.credentials.dig(:tdx, :base_url)
        return credential_value if credential_value && !credential_value.empty?
      end

      # Fall back to ENV variable
      env_value = ENV['TDX_BASE_URL']
      return env_value if env_value && !env_value.empty?

      # Default based on environment
      default_url_for_environment
    end

    def resolve_oauth_token_url
      # First check Rails encrypted credentials for environment-specific values
      if defined?(Rails) && Rails.application&.credentials
        # Try environment-specific credentials first
        env_key = environment_key
        if env_key
          credential_value = Rails.application.credentials.dig(:tdx, env_key, :oauth_token_url)
          return credential_value if credential_value && !credential_value.empty?
        end

        # Fall back to general credential
        credential_value = Rails.application.credentials.dig(:tdx, :oauth_token_url)
        return credential_value if credential_value && !credential_value.empty?
      end

      # Fall back to ENV variable
      env_value = ENV['TDX_OAUTH_TOKEN_URL']
      return env_value if env_value && !env_value.empty?

      # Default based on environment
      default_oauth_url_for_environment
    end

    def environment_key
      return :production if production?
      return :staging if staging?
      return :development if development?
      nil
    end

    def production?
      defined?(Rails) && Rails.env.production?
    rescue
      false
    end

    def staging?
      defined?(Rails) && (Rails.env.staging? || Rails.env.test?)
    rescue
      false
    end

    def development?
      defined?(Rails) && Rails.env.development?
    rescue
      false
    end

    def default_url_for_environment
      if production?
        'https://gw.api.it.umich.edu/um/it'
      else
        'https://gw-test.api.it.umich.edu/um/it'
      end
    end

    def default_oauth_url_for_environment
      if production?
        'https://gw.api.it.umich.edu/um/oauth2/token'
      else
        'https://gw-test.api.it.umich.edu/um/oauth2/token'
      end
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
