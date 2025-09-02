# TDX Feedback Gem

A Rails engine that provides a seamless, modal-based feedback system for any Rails application. Users can submit feedback without leaving your main application, and the system integrates with TDX API for ticket creation.

## Features

- **Modal-based feedback system** - No page navigation required
- **Seamless integration** - Drop into any Rails application
- **TDX API integration** - Automatically creates support tickets
- **Responsive design** - Works on all device sizes
- **Customizable styling** - Easy to match your app's design
- **Authentication support** - Optional user authentication requirement
- **Stimulus-powered** - Modern JavaScript framework integration
- **Zero-configuration assets** - JavaScript and CSS automatically included

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

## Configuration

The gem automatically resolves configuration from:

1. **[Rails Encrypted Credentials** (recommended)](https://github.com/lsa-mis/tdx-feedback_gem/wiki/Configuration-Guide#environment-specific-configuration)**
2. **[Environment Variables](https://github.com/lsa-mis/tdx-feedback_gem/wiki/Configuration-Guide#environment-variables)**
3. **Built-in defaults**

### Runtime Toggle

Enable/disable TDX ticket creation without redeploying:

```bash
export TDX_ENABLE_TICKET_CREATION=true
```

## Documentation

- **[📚 Wiki](https://github.com/lsa-mis/tdx-feedback_gem/blob/main/wiki/Home.md)** - Complete documentation, examples, and guides
- **[🔧 Integration Examples](https://github.com/lsa-mis/tdx-feedback_gem/wiki/Integration-Examples)** - Rails 5/6/7, authentication systems
- **[🎨 Styling Guide](https://github.com/lsa-mis/tdx-feedback_gem/wiki/Styling-and-Theming)** - Customization and theming
- **[🧪 Testing Guide](https://github.com/lsa-mis/tdx-feedback_gem/wiki/Testing-Guides)** - Test setup and coverage
- **[📊 API Schemas](https://github.com/lsa-mis/tdx-feedback_gem/wiki/API-Schemas)** - TDX API specifications

## Development

```bash
git clone https://github.com/lsa-mis/tdx-feedback_gem.git
cd tdx_feedback_gem
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/lsa-mis/tdx-feedback_gem/issues).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
