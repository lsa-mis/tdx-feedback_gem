# TDX Feedback Gem

A Rails engine that provides a seamless, modal-based feedback system for any Rails application. Users can submit feedback without leaving your main application, and the system can integrate with the TDX API for ticket creation when enabled.

## Features

- **Modal-based feedback system** - No page navigation required
- **Seamless integration** - Drop into any Rails application
- **TDX API integration** - Optionally creates support tickets (when enabled)
- **Responsive design** - Works on all device sizes
- **Customizable styling** - Easy to match your app's design
- **Authentication support** - Optional user authentication requirement
- **Stimulus-powered** - Modern JavaScript framework integration
- **Generator-wired assets** - Installer adds the JavaScript and CSS for you

## Quick Start

### 1. Installation

Add to your Gemfile:

```ruby
gem 'tdx_feedback_gem', git: 'https://github.com/lsa-mis/tdx-feedback_gem.git'
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

**That's it!** The gem automatically:

- ✅ Creates the necessary database migration
- ✅ Sets up the initializer with default configuration
- ✅ Copies the Stimulus controller to your app
- ✅ Includes the CSS styles in your asset pipeline
- ✅ Registers the helper methods globally

### 3. Configuration (Optional)

Edit `config/initializers/tdx_feedback_gem.rb` if you need custom settings:

```ruby
TdxFeedbackGem.configure do |config|
  config.require_authentication = true
  config.enable_ticket_creation = false
  config.oauth_scope = 'tdxticket'
  config.title_prefix = '[Feedback]'

  # TDX API credentials (use Rails credentials or environment variables)
  config.app_id = 31
  config.type_id = 12
  config.status_id = 77
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631
end
```

### 4. Usage

Add to your layout or views:

```erb
<%= feedback_footer_link %>
<%= feedback_header_button %>
<%= feedback_system(trigger: :button, text: 'Send Feedback') %>
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

## Documentation

- **[📚 Wiki](wiki/Home.md)** - Complete documentation, examples, and guides
- **[� Getting Started](wiki/Getting-Started.md)** - Quick overview and setup details
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
