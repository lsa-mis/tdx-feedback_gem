# frozen_string_literal: true

TdxFeedbackGem.configure do |config|
  # Require an authenticated user (expects `current_user`) to submit feedback
  # config.require_authentication = true

  # --- TeamDynamix (TDX) API Settings ---
  # Enable ticket creation via the TDX API when feedback is submitted
  # config.enable_ticket_creation = true

  # API base URL and OAuth token endpoint (automatically resolved from credentials or ENV)
  #
  # Priority order for URLs:
  # 1. Rails.application.credentials.tdx[:environment][:base_url] (e.g., tdx.development.base_url)
  # 2. Rails.application.credentials.tdx.base_url
  # 3. ENV['TDX_BASE_URL']
  # 4. Environment-specific defaults (gw-test for dev/staging, gw for production)
  #
  # You can override manually if needed:
  # config.tdx_base_url = 'https://gw-test.api.it.umich.edu/um/it'
  # config.oauth_token_url = 'https://gw-test.api.it.umich.edu/um/oauth2/token'

  # OAuth2 client credentials (automatically resolved from Rails credentials or ENV)
  # Priority: Rails.application.credentials.tdx_client_id -> ENV['TDX_CLIENT_ID']
  # Priority: Rails.application.credentials.tdx_client_secret -> ENV['TDX_CLIENT_SECRET']
  #
  # You can override manually if needed:
  # config.client_id = 'your_client_id'
  # config.client_secret = 'your_client_secret'
  # config.oauth_scope = 'tdxticket'

  # Ticket defaults (required by TDX CreateTicket schema)
  # config.app_id = 46
  # config.type_id = 644
  # config.form_id = 107
  # config.service_offering_id: 289
  # config.status_id = 115
  # config.source_id = 8
  # config.service_id = 2314
  # config.responsible_group_id = 388

  # Optional UI/labeling
  # config.title_prefix = '[Feedback]'
  # config.default_requestor_email = 'noreply@example.com'
end
