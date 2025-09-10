# frozen_string_literal: true

if defined?(TdxFeedbackGem)
  TdxFeedbackGem.configure do |config|
    # Require an authenticated user (expects `current_user`)
    # config.require_authentication = true

    # Enable ticket creation and set ID defaults (uncomment & customize)
    # config.enable_ticket_creation = true
    # config.app_id = 46
    # config.type_id = 644
    # config.form_id = 107
    # config.service_offering_id = 289
    # config.status_id = 115
    # config.source_id = 8
    # config.service_id = 2314
    # config.responsible_group_id = 388

    # Auto-importmap pin (disable if you manually manage importmap.rb)
    # config.auto_pin_importmap = true

    # Runtime SCSS copy (dev/test convenience only)
    # config.runtime_scss_copy = Rails.env.development? || Rails.env.test?

    # UI label prefix for created tickets
    # config.title_prefix = '[Feedback]'
  end
end
