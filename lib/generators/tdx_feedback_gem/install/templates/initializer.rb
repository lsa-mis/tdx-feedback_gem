# frozen_string_literal: true

if defined?(TdxFeedbackGem)
  TdxFeedbackGem.configure do |config|
    # Require an authenticated user (expects `current_user`)
    # config.require_authentication = true

    # Enable ticket creation and set ID defaults (uncomment & customize)
    # Note: These can also be configured via Rails credentials or environment variables
    # config.enable_ticket_creation = true
    # config.app_id = 0
    # config.type_id = 1
    # config.form_id = 1
    # config.service_offering_id = 2
    # config.status_id = 1
    # config.source_id = 1
    # config.service_id = 1
    # config.responsible_group_id = 1

    # Optional: Account/department ID for ticket organization
    # Can be configured via credentials: tdx.development.account_id: 2
    # Or environment variable: TDX_ACCOUNT_ID=2
    # config.account_id = 2

    # Default requestor email (fallback when user is not authenticated)
    # config.default_requestor_email = 'noreply@example.com'

    # Auto-importmap pin (disable if you manually manage importmap.rb)
    # config.auto_pin_importmap = true

    # Runtime SCSS copy (dev/test convenience only)
    # config.runtime_scss_copy = Rails.env.development? || Rails.env.test?

    # UI label prefix for created tickets
    # config.title_prefix = '[Feedback]'
  end

  # Configuration Resolution Priority:
  # 1. Rails Encrypted Credentials (highest priority)
  # 2. Environment Variables (medium priority)
  # 3. Initializer Settings (lowest priority)
  #
  # Example credentials configuration:
  # tdx:
  #   development:
  #     enable_ticket_creation: 'true'  # Note: string values
  #     account_id: 2
  #   production:
  #     enable_ticket_creation: 'true'
  #     account_id: 2
  #
  # Example environment variables:
  # TDX_ENABLE_TICKET_CREATION=true
  # TDX_ACCOUNT_ID=2
  #
  # The gem automatically resolves these settings after Rails initialization
  # and logs the resolution for debugging purposes.
end
