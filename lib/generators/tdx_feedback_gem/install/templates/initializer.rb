# frozen_string_literal: true

TdxFeedbackGem.configure do |config|
  # Require an authenticated user (expects `current_user`) to submit feedback
  # config.require_authentication = true

  # --- TeamDynamix (TDX) API Settings ---
  # Enable ticket creation via the TDX API when feedback is submitted
  # config.enable_ticket_creation = true

  # API base URL and OAuth token endpoint (example values for UM test gateway)
  # config.tdx_base_url = 'https://gw-test.api.it.umich.edu/um/it'
  # config.oauth_token_url = 'https://gw-test.api.it.umich.edu/um/it/oauth2/token'

  # OAuth2 client credentials (prefer reading from ENV)
  # config.client_id = ENV['TDX_CLIENT_ID']
  # config.client_secret = ENV['TDX_CLIENT_SECRET']
  # config.oauth_scope = 'tdxticket'

  # Ticket defaults (required by TDX CreateTicket schema)
  # config.app_id = 31
  # config.type_id = 12
  # config.status_id = 77
  # config.source_id = 8
  # config.service_id = 67
  # config.responsible_group_id = 631

  # Optional UI/labeling
  # config.title_prefix = '[Feedback]'
  # config.default_requestor_email = 'noreply@example.com'
end
