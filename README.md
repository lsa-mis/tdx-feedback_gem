# TDX Feedback Gem

A Rails engine that provides a seamless, modal-based feedback system for any Rails application. Users can submit feedback without leaving your main application, and the system can integrate with the TDX API for ticket creation when enabled.

## Features

- **Modal-based feedback system** - No page navigation required
- **Seamless integration** - Drop into any Rails application
- **TDX API integration** - Optionally creates support tickets (when enabled)
- **Account/department organization** - Optional AccountID support for ticket routing
- **Enhanced credentials resolution** - Properly reads Rails credentials after initialization
- **JSON payload logging** - Debug TDX API requests with detailed logging
- **Responsive design** - Works on all device sizes
- **Customizable styling** - Easy to match your app's design
- **Authentication support** - Optional user authentication requirement
- **Stimulus-powered** - Modern JavaScript framework integration
- **Generator-wired assets** - Installer adds the JavaScript and CSS for you
- **Automatic Importmap pinning** - Controller auto-pinned (can be disabled)
- **Optional runtime SCSS copy (dev/test)** - Avoids mutating production builds

## Requirements

- **Ruby 3.0+** (required by gemspec)
- **Rails 6.1+** (tested with Rails 6.x and 7.x)
- **Database** (PostgreSQL, MySQL, SQLite3 supported)

## Quick Start

### 1. Installation

Add to your Gemfile:

```ruby
gem 'tdx_feedback_gem', '~> 0.1.6'
```

### 2. Setup

```bash
bundle install
rails generate tdx_feedback_gem:install
rails db:migrate
```

Add the engine to your host app routes (recommended mount path shown):

```ruby
# config/routes.rb
mount TdxFeedbackGem::Engine => '/tdx_feedback_gem'
```

Recompile your assets:

```bash
bundle exec rake assets:clobber && bundle exec rake dartsass:build
bundle exec rake assets:precompile
```

**That's it!** The gem automatically:

- ✅ Creates the necessary database migration
- ✅ Sets up the initializer with default configuration
- ✅ Copies the Stimulus controller to your app
- ✅ Includes the CSS styles in your asset pipeline
- ✅ Registers the helper methods globally
- ✅ Validates configuration at boot and logs non-fatal warnings (missing IDs, unsafe flags, missing importmap)

### Importmap Notes

If your app uses Importmap the engine will automatically attempt to pin its Stimulus controller when `auto_pin_importmap` is enabled (default). The engine only adds its `app/javascript` path to Importmap when an `importmap.json` file is present (avoids mutating frozen configs in some setups).

Disable auto pinning (manual control):

```bash
export TDX_FEEDBACK_GEM_AUTO_PIN=false
```

Then ensure you have a manual pin in `config/importmap.rb`:

```ruby
pin_all_from 'app/javascript/controllers', under: 'controllers'
```

### 3. Configuration (Optional)

Edit `config/initializers/tdx_feedback_gem.rb` if you need custom settings:

```ruby
TdxFeedbackGem.configure do |config|
  config.require_authentication = true
  # config.enable_ticket_creation = false
  config.oauth_scope = 'tdxticket'
  config.title_prefix = '[Feedback]'

  # TDX API credentials (use Rails credentials or environment variables)
  config.app_id = 31
  config.type_id = 12
  config.status_id = 77
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631

  # Optional TDX configuration
  config.account_id = 2  # Account/department ID for ticket organization
end
```

### Enhanced Configuration Resolution

The gem now properly resolves configuration from multiple sources with improved timing:

1. **Rails Encrypted Credentials** (highest priority)
2. **Environment Variables** (medium priority)
3. **Initializer Settings** (lowest priority)

**Account ID Configuration:**
```ruby
# In credentials.yml.enc
tdx:
  development:
    account_id: 21
    enable_ticket_creation: 'true'  # Note: string values
  production:
    account_id: 21
    enable_ticket_creation: 'true'
```

**Environment Variables:**
```bash
export TDX_ACCOUNT_ID=21
export TDX_ENABLE_TICKET_CREATION=true
```

### Debug Logging

The gem now includes detailed JSON payload logging for TDX API requests:

```
TDX API Request - App ID: 46
TDX API Request - Payload: {
  "TypeID": 644,
  "FormID": 107,
  "ServiceOfferingID": 289,
  "StatusID": 115,
  "SourceID": 8,
  "ServiceID": 2314,
  "ResponsibleGroupID": 388,
  "Title": "[MyApp Feedback] User feedback message",
  "Description": "User feedback message\n--- Context ---\nAdditional context",
  "IsRichHtml": false,
  "RequestorEmail": "user@example.com",
  "AccountID": 21
}
```
```

### 4. Usage

Add to your layout or views:

```erb
<%= feedback_system(trigger: :link, text: 'Feedback', class: 'tdx-feedback-footer-link') %>
<%= feedback_system(trigger: :button, text: 'Send Feedback') %>
<%= feedback_footer_link %>
<%= feedback_header_button %>
```

If you mount the engine at a different path than `/tdx_feedback_gem`, either:

- Pass custom URLs via Stimulus values on your trigger element:
  - `data-tdx-feedback-new-url-value="/feedback/feedbacks/new"`
  - `data-tdx-feedback-submit-url-value="/feedback/feedbacks"`
- Or mount at `/tdx_feedback_gem` to use the controller defaults.

## Configuration

The gem automatically resolves configuration from:

1. **[Rails Encrypted Credentials (recommended)](wiki/Configuration-Guide.md#environment-specific-configuration)**
2. **[Environment Variables](wiki/Configuration-Guide.md#environment-variables)**
3. **Built-in defaults**

### Runtime Toggle

Enable/disable TDX ticket creation without redeploying:

```bash
export TDX_ENABLE_TICKET_CREATION=true
```

### Front-end Behavior Flags

Disable automatic Importmap pinning (if you prefer manual control):

```bash
export TDX_FEEDBACK_GEM_AUTO_PIN=false
```

Disable runtime SCSS copying (normally already false in production):

```bash
export TDX_FEEDBACK_GEM_RUNTIME_SCSS_COPY=false
```

Update assets (after gem upgrade) to refresh the SCSS partial & controller:

```bash
rails g tdx_feedback_gem:update_assets
```

## Upgrade

After bumping the gem version:

1. Run `bundle install`
2. (Optional) Re-run the installer if you want newly added initializer comments: `rails g tdx_feedback_gem:install`
3. Refresh front-end assets (controller / SCSS) if desired: `rails g tdx_feedback_gem:update_assets`
4. Review the CHANGELOG for behavioral changes
5. Check application logs on boot for any `tdx_feedback_gem configuration warning` messages

## Documentation

- **[📚 Wiki](wiki/Home.md)** - Complete documentation, examples, and guides
- **[🚀 Getting Started](wiki/Getting-Started.md)** - Quick overview and setup details
- **[⚙️ Configuration Guide](wiki/Configuration-Guide.md)** - Credentials, env vars, and defaults
- **[🔧 Integration Examples](wiki/Integration-Examples.md)** - Rails 5/6/7, authentication systems
- **[🎨 Styling and Theming](wiki/Styling-and-Theming.md)** - Customization and theming
- **[🧪 Testing Guide](wiki/Testing-Guide.md)** - Test setup and coverage
- **[🩺 Troubleshooting](wiki/Troubleshooting.md)** - Common issues and fixes
- **[📊 API Schemas](wiki/API-Schemas.md)** - TDX API specifications
- **[🧰 Helper Methods Reference](wiki/Helper-Methods-Reference.md)** - All view helpers and options
- **[⚡ Stimulus API Reference](wiki/Stimulus-API-Reference.md)** - Controller events and targets

## Development

```bash
git clone https://github.com/lsa-mis/tdx-feedback_gem.git
cd tdx-feedback_gem
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lsa-mis/tdx-feedback_gem/issues).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
