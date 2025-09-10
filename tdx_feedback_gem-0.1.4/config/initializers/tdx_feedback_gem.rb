# frozen_string_literal: true

TdxFeedbackGem.configure do |config|
  # Require an authenticated user (expects `current_user`) to submit feedback
  # config.require_authentication = true

  # --- TeamDynamix (TDX) API Settings ---
  # Enable ticket creation via the TDX API when feedback is submitted
  # config.enable_ticket_creation = false

  # All TDX API settings are automatically resolved from Rails credentials or environment variables
  #
  # Resolution priority (highest to lowest):
  # 1. Rails.application.credentials.tdx[:environment][:setting] (e.g., tdx.development.client_id)
  # 2. Rails.application.credentials.tdx_[:setting] (e.g., tdx_client_id)
  # 3. ENV['TDX_[:SETTING]'] (e.g., TDX_CLIENT_ID)
  # 4. Built-in defaults (URLs only)
  #
  # Examples for environment-specific credentials:
  # - Development: Rails.application.credentials.tdx[:development][:client_id]
  # - Staging: Rails.application.credentials.tdx[:staging][:client_id]
  # - Production: Rails.application.credentials.tdx[:production][:client_id]
  #
  # You can override manually if needed:
  # config.tdx_base_url = 'https://gw-test.api.it.umich.edu/um/it'
  # config.oauth_token_url = 'https://gw-test.api.it.umich.edu/um/oauth2/token'
  # config.client_id = 'your_client_id'
  # config.client_secret = 'your_client_secret'
  # config.oauth_scope = 'tdxticket'

  # Ticket defaults (required by TDX CreateTicket schema)
  # config.app_id = 46
  # config.type_id = 644
  # config.form_id = 107
  # config.service_offering_id = 289
  # config.status_id = 115
  # config.source_id = 8
  # config.service_id = 2314
  # config.responsible_group_id = 388

  # Optional UI/labeling
  # config.title_prefix = '[Feedback]'
  # config.default_requestor_email = 'noreply@example.com'
end
