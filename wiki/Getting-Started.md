# Getting Started

This guide will walk you through installing and setting up the TDX Feedback Gem in your Rails application.

## 📋 Prerequisites

- **Rails 5.2+** (tested with Rails 5.2, 6.x, and 7.x)
- **Ruby 2.6+** (recommended: Ruby 3.0+)
- **Database** (PostgreSQL, MySQL, SQLite3 supported)
- **TDX API Access** (client ID, client secret, and configuration values)

## 🚀 Installation

### Step 1: Add to Gemfile

Add the gem to your application's Gemfile:

```ruby
# Gemfile
gem 'tdx_feedback_gem', git: 'https://github.com/lsa-mis/tdx-feedback_gem.git'
```

### Step 2: Install Dependencies

```bash
bundle install
```

### Step 3: Run the Install Generator

```bash
rails generate tdx_feedback_gem:install
```

This creates:

- `config/initializers/tdx_feedback_gem.rb` - Configuration file
- `db/migrate/[timestamp]_create_tdx_feedback_gem_feedbacks.rb` - Database migration
- Copies the Stimulus controller into your app at `app/javascript/controllers/tdx_feedback_controller.js` when Stimulus is detected.

### Step 4: Run Database Migration

```bash
rails db:migrate
```

## ⚙️ Basic Configuration

Edit the generated configuration file:

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  # === Authentication ===
  config.require_authentication = true  # Set to true if you want user authentication

  # === TDX API Integration ===
  config.enable_ticket_creation = false  # Set to true when ready for production

  # === TDX Ticket Configuration ===
  # Get these values from your TDX administrator
  config.app_id = 31                    # Application ID
  config.type_id = 12                   # Ticket type ID
  config.status_id = 77                 # Initial status ID
  config.source_id = 8                  # Ticket source ID
  config.service_id = 67                # Service ID
  config.responsible_group_id = 631     # Responsible group ID

  # === Optional Configuration ===
  config.account_id = 2                 # Account/department ID for ticket organization

  # === Customization ===
  config.title_prefix = '[Feedback]'    # Prefix for ticket titles
  config.default_requestor_email = 'noreply@example.com'  # Fallback email
end
```

## 🔑 TDX API Credentials

The gem automatically resolves sensitive configuration from Rails encrypted credentials or environment variables.

### Option 1: Rails Credentials (Recommended)

```bash
# Edit credentials
bin/rails credentials:edit
```

Add to your credentials:

```yaml
# credentials.yml.enc
tdx:
  client_id: your_client_id_here
  client_secret: your_client_secret_here
  base_url: https://gw-test.api.it.umich.edu/um/it
  oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
```

### Option 2: Environment Variables

```bash
# .env or your environment configuration
TDX_CLIENT_ID=your_client_id_here
TDX_CLIENT_SECRET=your_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token
```

## 🎯 First Feedback Form

### Add to Your Layout

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Your App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

  <%= stylesheet_link_tag 'application', media: 'all' %>
  <%= javascript_include_tag 'application' %>
  </head>

  <body>
    <%= yield %>

  <!-- Add feedback system (modal + trigger) near the end of body -->
  <%= feedback_system(trigger: :button, text: 'Send Feedback') %>
  </body>
</html>
```

### Alternative Placements

```erb
<!-- In header -->
<%= feedback_header_button %>

<!-- Custom button -->
<%= feedback_system(trigger: :button, text: 'Send Feedback', class: 'btn-primary') %>
-or-
<%= feedback_system(trigger: :link, text: 'Feedback', class: 'tdx-feedback-footer-link') %>

<!-- Icon only -->
<%= feedback_icon(class: 'header-icon') %>
```

## 🧪 Test Your Setup

### 1. Start Your Server

```bash
rails server
```

### 2. Visit Any Page

Navigate to any page in your application. You should see the feedback trigger (link, button, or icon).

### 3. Test the Modal

Click the feedback link/button. A modal should open with the feedback form.

### 4. Submit Test Feedback

Fill out the form and submit. Check your database to see if the feedback was created.

### 5. Verify the Feedback was Created

```bash
# Check if the table was created
rails console
```

```ruby
# In Rails console
TdxFeedbackGem::Feedback.count
# Should return 0 (or the number of feedbacks you've created)
```

### 6. Verify the Feedback was Created in TDX

Log onto the [TDX system](https://teamdynamix.umich.edu/SBTDWorkManagement) and check if the feedback was created.

## ✅ Verify Installation

### Check Database

```bash
# Check if the table was created
rails console
```

```ruby
# In Rails console
TdxFeedbackGem::Feedback.count
# Should return 0 (or the number of feedbacks you've created)
```

### Check Routes

```bash
rails routes | grep tdx_feedback
```

You should see JSON-only endpoints:

```
tdx_feedback_gem_feedbacks GET    /tdx_feedback_gem/feedbacks/new(.:format) tdx_feedback_gem/feedbacks#new {:format=>:json}
                           POST   /tdx_feedback_gem/feedbacks(.:format)     tdx_feedback_gem/feedbacks#create {:format=>:json}
```

Note: The engine responds with JSON; the Stimulus controller injects the returned HTML into the DOM.

### Stimulus and Assets

- The engine precompiles `tdx_feedback_gem.css`. If your app uses SCSS, the engine will place `_tdx_feedback_gem.scss` into your app's stylesheets so you can `@import` it from `application.scss`.
- The Stimulus controller is available at `app/javascript/controllers/tdx_feedback_controller.js`. Ensure it's registered by adding the import to your `controllers/index.js` (or equivalent):

```js
// app/javascript/controllers/index.js
import { application } from "./application"
import TdxFeedbackController from "./tdx_feedback_controller"

application.register("tdx-feedback", TdxFeedbackController)
```

## 🚨 Common Issues

### Issue: Modal Not Opening

**Possible Causes:**

- JavaScript not loading
- CSS conflicts
- Stimulus not initialized

**Solutions:**

- Check browser console for JavaScript errors
- Verify Stimulus registration (see Stimulus and Assets above)
- Check that `/tdx_feedback_gem/feedbacks/new` returns JSON 200 in Network tab
- Ensure CSS is loaded (`tdx_feedback_gem.css` or imported SCSS)

### Issue: Form Not Submitting

**Possible Causes:**

- CSRF token issues
- Database connection problems
- Validation errors

**Solutions:**

- Check CSRF token is present (Rails includes it by default)
- Verify database connection and run migrations
- Confirm `/tdx_feedback_gem/feedbacks` POST returns JSON 201
- Check Rails logs for validation errors

### Issue: TDX Integration Not Working

**Possible Causes:**

- Invalid credentials
- Network connectivity issues
- Configuration errors

**Solutions:**

- Verify TDX credentials
- Check network access to TDX API
- Review configuration values

## 🔄 Next Steps

Now that you have the basic setup working:

1. **[Configuration Guide](Configuration-Guide)** - Learn about all configuration options
2. **[Styling and Theming](Styling-and-Theming)** - Customize the appearance
3. **[Integration Examples](Integration-Examples)** - See examples for different Rails versions
4. **[Testing Guide](Testing-Guide)** - Set up testing for your integration

## 🆘 Still Having Issues?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review the [Configuration Guide](Configuration-Guide)
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub
- Check the [README](https://github.com/lsa-mis/tdx-feedback_gem/blob/main/README.md) for basic information

---

*Need help with a specific step? Check the [Configuration Guide](Configuration-Guide) for detailed configuration options.*
