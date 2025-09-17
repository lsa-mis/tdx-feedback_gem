# frozen_string_literal: true

module TdxFeedbackGem
  class Configuration
    attr_accessor :require_authentication

    # TDX API base URL, OAuth credentials, and scope
    attr_accessor :tdx_base_url, :oauth_token_url, :client_id, :client_secret, :oauth_scope

    # Ticket creation toggles and defaults
    attr_accessor :enable_ticket_creation, :app_id, :type_id, :form_id, :service_offering_id,
                  :status_id, :source_id, :service_id, :responsible_group_id, :account_id, :title_prefix, :default_requestor_email

    # Front-end / integration behavior toggles
    attr_accessor :auto_pin_importmap, :runtime_scss_copy

    def initialize
      @require_authentication = false

      # Resolve URLs from credentials or ENV based on environment
      @tdx_base_url      = resolve_tdx_base_url
      @oauth_token_url   = resolve_oauth_token_url
      @client_id         = resolve_client_id
      @client_secret     = resolve_client_secret
      @oauth_scope       = 'tdxticket'

      @enable_ticket_creation = resolve_enable_ticket_creation
      @app_id                 = nil
      @type_id                = nil
      @form_id                = nil
      @service_offering_id    = nil
      @status_id              = nil
      @source_id              = nil
      @service_id             = nil
      @responsible_group_id   = nil
      @account_id             = resolve_account_id
      @title_prefix           = '[Feedback]'
      @default_requestor_email = nil

      # New toggles with precedence (credentials -> ENV -> default)
      @auto_pin_importmap = resolve_auto_pin_importmap
      @runtime_scss_copy  = resolve_runtime_scss_copy
    end

    # Note: use the generated writer from attr_accessor for enable_ticket_creation

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

      # No built-in default. Require credentials or ENV to provide this.
      nil
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

      # No built-in default. Require credentials or ENV to provide this.
      nil
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

    # Removed environment-specific hardcoded defaults to avoid exposing institution-specific URLs

    def resolve_enable_ticket_creation
      # First check Rails encrypted credentials for environment-specific values
      if defined?(Rails) && Rails.application&.credentials
        # Try environment-specific credentials first
        env_key = environment_key
        if env_key
          credential_value = Rails.application.credentials.dig(:tdx, env_key, :enable_ticket_creation)
          return credential_value.downcase == 'true' if credential_value && credential_value.respond_to?(:downcase)
        end

        # Fall back to general credential
        credential_value = Rails.application.credentials.dig(:tdx, :enable_ticket_creation)
        return credential_value.downcase == 'true' if credential_value && credential_value.respond_to?(:downcase)
      end

      # Fall back to ENV variable
      env_value = ENV['TDX_ENABLE_TICKET_CREATION']
      return env_value.downcase == 'true' if env_value && !env_value.empty?

      # Fall back to default value
      false
    end

    def resolve_account_id
      # First check Rails encrypted credentials for environment-specific values
      if defined?(Rails) && Rails.application&.credentials
        # Try environment-specific credentials first
        env_key = environment_key
        if env_key
          credential_value = Rails.application.credentials.dig(:tdx, env_key, :account_id)
          return credential_value.to_i if credential_value
        end

        # Fall back to general credential
        credential_value = Rails.application.credentials.dig(:tdx, :account_id)
        return credential_value.to_i if credential_value
      end

      # Fall back to ENV variable
      env_value = ENV['TDX_ACCOUNT_ID']
      return env_value.to_i if env_value && !env_value.empty?

      # Fall back to default value
      nil
    end

    def resolve_auto_pin_importmap
      # Credentials lookup (environment-specific then general)
      if defined?(Rails) && Rails.application&.credentials
        env_key = environment_key
        if env_key
          cred_val = Rails.application.credentials.dig(:tdx, env_key, :auto_pin_importmap)
          return truthy?(cred_val) unless cred_val.nil?
        end
        cred_val = Rails.application.credentials.dig(:tdx, :auto_pin_importmap)
        return truthy?(cred_val) unless cred_val.nil?
      end

      # ENV override
      env_val = ENV['TDX_FEEDBACK_GEM_AUTO_PIN']
      return truthy?(env_val) unless env_val.nil? || env_val.empty?

      # Default
      true
    end

    def resolve_runtime_scss_copy
      # Credentials
      if defined?(Rails) && Rails.application&.credentials
        env_key = environment_key
        if env_key
          cred_val = Rails.application.credentials.dig(:tdx, env_key, :runtime_scss_copy)
          return truthy?(cred_val) unless cred_val.nil?
        end
        cred_val = Rails.application.credentials.dig(:tdx, :runtime_scss_copy)
        return truthy?(cred_val) unless cred_val.nil?
      end

      # ENV
      env_val = ENV['TDX_FEEDBACK_GEM_RUNTIME_SCSS_COPY']
      return truthy?(env_val) unless env_val.nil? || env_val.empty?

      # Default: only in development & test for safety
      development? || staging? # allow in test/staging-like envs for easier iteration
    end

    # Validate configuration and emit helpful warnings without raising (non-fatal)
    def validate_configuration!
      if auto_pin_importmap && !defined?(Importmap)
        Rails.logger.warn("[tdx_feedback_gem] auto_pin_importmap enabled but Importmap not detected; no action taken") if defined?(Rails)
      end
      if runtime_scss_copy && defined?(Rails) && Rails.env.production?
        Rails.logger.warn("[tdx_feedback_gem] runtime_scss_copy should be disabled in production for immutable builds")
      end
      if enable_ticket_creation
        missing = []
        missing << 'tdx_base_url' if tdx_base_url.nil? || tdx_base_url.to_s.strip.empty?
        missing << 'oauth_token_url' if oauth_token_url.nil? || oauth_token_url.to_s.strip.empty?
        missing << 'client_id' if client_id.nil? || client_id.to_s.strip.empty?
        missing << 'client_secret' if client_secret.nil? || client_secret.to_s.strip.empty?
        if defined?(Rails) && !missing.empty?
          Rails.logger.warn("[tdx_feedback_gem] Ticket creation enabled but missing API configuration: #{missing.join(', ')}")
        end
      end
      if enable_ticket_creation && [app_id, type_id, form_id, service_offering_id, status_id, source_id, service_id, responsible_group_id].any?(&:nil?)
        Rails.logger.warn("[tdx_feedback_gem] Ticket creation enabled but one or more required IDs are nil (app_id/type_id/form_id/etc.)") if defined?(Rails)
      end
    end

    def truthy?(value)
      return value if value == true || value == false
      return true if value.respond_to?(:downcase) && %w[1 true yes on].include?(value.downcase)
      false
    end

    # Re-resolve credentials after Rails initialization
    # This ensures credentials are properly read even when the gem is loaded early
    def resolve_credentials_after_initialization!
      @enable_ticket_creation = resolve_enable_ticket_creation
      @account_id = resolve_account_id

      # Log the resolution for debugging
      if defined?(Rails) && Rails.logger
        Rails.logger.info "TDX Feedback Gem: Resolved enable_ticket_creation=#{@enable_ticket_creation} from credentials/ENV"
        Rails.logger.info "TDX Feedback Gem: Resolved account_id=#{@account_id} from credentials/ENV" if @account_id
      end
    end

    public :resolve_credentials_after_initialization!
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
