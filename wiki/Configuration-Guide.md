# Configuration Guide

Complete guide to configuring the TDX Feedback Gem for your Rails application.

## 📋 Configuration Overview

The gem uses a hierarchical configuration system that automatically resolves values from multiple sources:

1. **Rails Encrypted Credentials** (highest priority – recommended for production)
2. **Environment Variables** (medium priority – good for deployment)
3. **Built-in Defaults** (none for API URLs; provide via credentials/ENV)

## ⚙️ Basic Configuration

### Configuration Block

All configuration is done in the initializer file:

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  # Your configuration here
end
```

### Essential Settings

```ruby
TdxFeedbackGem.configure do |config|
  # === Authentication ===
  config.require_authentication = true

  # === TDX API Integration ===
  config.enable_ticket_creation = false

  # === TDX Ticket Configuration ===
  config.app_id = 31
  config.type_id = 12
  config.status_id = 77
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631

  # === Customization ===
  config.title_prefix = '[Feedback]'
end
```

## 🔐 Authentication Configuration

### User Authentication

```ruby
config.require_authentication = true  # Requires current_user method
```

**Requirements:**

- Your `ApplicationController` should expose a `current_user` method
- When `require_authentication` is true and `current_user` is missing, the engine responds with `401 Unauthorized` to `/feedbacks/new` and `/feedbacks` requests (triggers may still render; protect them in your views if desired)

**Example ApplicationController:**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def current_user
    # Your authentication logic here
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
```

### No Authentication

```ruby
config.require_authentication = false  # Anyone can submit feedback
```

## 🎫 TDX API Configuration

### Enable/Disable Ticket Creation

```ruby
config.enable_ticket_creation = true  # Creates TDX tickets
config.enable_ticket_creation = false # Only stores feedback locally
```

### Runtime Toggle (No Redeploy Required)

You can enable/disable TDX ticket creation at runtime using environment variables:

```bash
# Enable TDX ticket creation
export TDX_ENABLE_TICKET_CREATION=true

# Disable TDX ticket creation
export TDX_ENABLE_TICKET_CREATION=false
```

Use cases:

- Toggling during incidents or maintenance
- Testing in different environments
- Container orchestration (Docker, Kubernetes)
- DevOps/SRE team control without developer involvement

### TDX API Endpoints

```ruby
config.tdx_base_url = 'https://api.example.com/'
config.oauth_token_url = 'https://api.example.com/'
```

### OAuth Configuration

```ruby
config.oauth_scope = 'tdxticket'  # OAuth scope for TDX API
```

## 🎯 TDX Ticket Configuration

### Required Fields

These values must be obtained from your TDX administrator:

```ruby
config.app_id = 31                    # Application ID in TDX
config.type_id = 12                   # Ticket type ID
config.status_id = 77                 # Initial status ID
config.source_id = 8                  # Ticket source ID
config.service_id = 67                # Service ID
config.responsible_group_id = 631     # Responsible group ID
```

### Optional Fields

```ruby
config.form_id = 123                  # Form ID (if using custom forms)
config.service_offering_id = 456      # Service offering ID
config.account_id = 2                 # Account/department ID for ticket organization
```

**Note:** `account_id` can be configured via credentials or environment variables:
- Credentials: `tdx.development.account_id: 21`
- Environment: `TDX_ACCOUNT_ID=21`

## 🎨 Customization Options

### Ticket Appearance

```ruby
config.title_prefix = '[Feedback]'    # Prefix for ticket titles
config.default_requestor_email = 'noreply@example.com'  # Fallback email

# Front-end behavior (Importmap & asset handling)
config.auto_pin_importmap = true      # Automatically pin Stimulus controller for Importmap users
config.runtime_scss_copy = Rails.env.development?  # Copy SCSS partial at runtime (dev/test convenience)
```

<!-- Modal-specific configuration options are not provided by the gem; customize via CSS/HTML in your app. -->

## 🔑 Credential Management

### Rails Encrypted Credentials (Recommended)

#### Setup

```bash
# Edit credentials (creates credentials.yml.enc and master.key)
bin/rails credentials:edit
```

#### Environment-Specific Configuration

```yaml
# credentials.yml.enc
tdx:
  development:
    client_id: dev_client_id_here
    client_secret: dev_client_secret_here
    base_url: https://api.example.com/
    oauth_token_url: https://api.example.com/
    enable_ticket_creation: 'false'  # Use string 'true'/'false'
    account_id: 2
  staging:
    client_id: staging_client_id_here
    client_secret: staging_client_secret_here
    base_url: https://api.example.com/
    oauth_token_url: https://api.example.com/
    enable_ticket_creation: 'true'   # Use string 'true'/'false'
    account_id: 2
  production:
    client_id: prod_client_id_here
    client_secret: prod_client_secret_here
    base_url: https://api.example.com/
    oauth_token_url: https://api.example.com/
    enable_ticket_creation: 'true'   # Use string 'true'/'false'
    account_id: 2
```

#### Shared Credentials with Environment-Specific URLs

```yaml
# Global TDX credentials (same for all environments)
tdx_client_id: your_shared_client_id_here
tdx_client_secret: your_shared_client_secret_here

# Environment-specific URLs only
tdx:
  development:
    base_url: https://api.example.com/
    oauth_token_url: https://api.example.com/
    enable_ticket_creation: 'false'  # Use string 'true'/'false'
  staging:
    base_url: https://api-staging.example.com/um/it
    oauth_token_url: https://api-staging.example.com/um/oauth2/token
    enable_ticket_creation: 'true'
  production:
    base_url: https://api.example.com/
    oauth_token_url: https://api.example.com/
    enable_ticket_creation: 'true'
```

### Environment Variables

#### Single Environment Configuration

```bash
# .env or your environment configuration
TDX_CLIENT_ID=your_client_id_here
TDX_CLIENT_SECRET=your_client_secret_here
TDX_BASE_URL=https://api.example.com/
TDX_OAUTH_TOKEN_URL=https://api.example.com/
TDX_ENABLE_TICKET_CREATION=false
TDX_FEEDBACK_GEM_AUTO_PIN=true
TDX_FEEDBACK_GEM_RUNTIME_SCSS_COPY=false
```

#### Environment-Specific .env Files

```bash
# .env.development (example)
TDX_CLIENT_ID=dev_client_id_here
TDX_CLIENT_SECRET=dev_client_secret_here
TDX_BASE_URL=https://api-dev.example.com/um/it
TDX_OAUTH_TOKEN_URL=https://api-dev.example.com/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=false
TDX_ACCOUNT_ID=2

# .env.staging (example)
TDX_CLIENT_ID=staging_client_id_here
TDX_CLIENT_SECRET=staging_client_secret_here
TDX_BASE_URL=https://api-staging.example.com/um/it
TDX_OAUTH_TOKEN_URL=https://api-staging.example.com/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=true
TDX_ACCOUNT_ID=2

# .env.production (example)
TDX_CLIENT_ID=prod_client_id_here
TDX_CLIENT_SECRET=prod_client_secret_here
TDX_BASE_URL=https://api.example.com/
TDX_OAUTH_TOKEN_URL=https://api.example.com/
TDX_ENABLE_TICKET_CREATION=true
TDX_ACCOUNT_ID=2
```

## 🚀 Deployment Platform Configuration

### Hatchbox.io

#### Access Environment Variables

1. Log into your Hatchbox.io dashboard
2. Navigate to your application
3. Click on **"Environment Variables"** in the left sidebar

> _Note: Be sure you have a variable declaring the server environment (i.e production or staging )_

|     Name    |   Value   |
|-------------|-----------|
| `RAILS_ENV` | `staging` |

#### Required Variables

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `TDX_ENABLE_TICKET_CREATION` | `true` | Enable TDX ticket creation |
| `TDX_CLIENT_ID` | `your_client_id` | TDX OAuth client ID |
| `TDX_CLIENT_SECRET` | `your_client_secret` | TDX OAuth client secret |
| `TDX_BASE_URL` | `https://api.example.com/` | TDX API base URL |
| `TDX_OAUTH_TOKEN_URL` | `https://api.example.com/` | OAuth token URL |
| `TDX_ACCOUNT_ID` | `2` | Production Account ID |

#### Development/Staging Variables

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `TDX_BASE_URL` | `https://api.example.com/` | Test TDX API URL |
| `TDX_OAUTH_TOKEN_URL` | `https://api.example.com/` | Test OAuth token URL |
| `TDX_FEEDBACK_GEM_AUTO_PIN` | `true` | Auto-pin Stimulus controller (Importmap) |
| `TDX_FEEDBACK_GEM_RUNTIME_SCSS_COPY` | `false` | Allow runtime SCSS partial copying |
| `TDX_ACCOUNT_ID` | `2` | Account ID |

#### Quick Toggle for Incidents

To temporarily disable TDX integration during incidents:

1. Go to **Environment Variables**
2. Change `TDX_ENABLE_TICKET_CREATION` from `true` to `false`
3. Click **"Save"**
4. Your application will automatically restart with the new setting

### Docker/Kubernetes

```yaml
# docker-compose.yml
environment:
  - TDX_ENABLE_TICKET_CREATION=true
  - TDX_CLIENT_ID=your_client_id
  - TDX_CLIENT_SECRET=your_client_secret
  - TDX_BASE_URL=https://api.example.com/
  - TDX_OAUTH_TOKEN_URL=https://api.example.com/
  - TDX_ACCOUNT_ID=2
```

```yaml
# kubernetes/deployment.yaml
env:
- name: TDX_ENABLE_TICKET_CREATION
  value: "true"
- name: TDX_CLIENT_ID
  valueFrom:
    secretKeyRef:
      name: tdx-secrets
      key: client-id
- name: TDX_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
      name: tdx-secrets
      key: client-secret
- name: TDX_ACCOUNT_ID
  value: "2"
```

### Heroku

```bash
heroku config:set TDX_ENABLE_TICKET_CREATION=true
heroku config:set TDX_CLIENT_ID=your_client_id
heroku config:set TDX_CLIENT_SECRET=your_client_secret
heroku config:set TDX_BASE_URL=https://api.example.com/
heroku config:set TDX_OAUTH_TOKEN_URL=https://api.example.com/
heroku config:set TDX_ACCOUNT_ID=2
```

## 🔄 Configuration Resolution Priority

### Priority Order

1. **Rails Encrypted Credentials** (highest priority)
   - Environment-specific credentials first (e.g., `tdx.production.client_id`)
   - Then global credentials (e.g., `tdx.client_id`)
2. **Environment Variables** (medium priority)
   - `TDX_CLIENT_ID`, `TDX_ENABLE_TICKET_CREATION`, etc.
3. There are no built-in defaults for API URLs; configure via credentials/ENV.
4. **Built-in Defaults** (lowest priority)
   - Development: `2`
   - Staging: `2`
   - Production: `2`

### Example Resolution

For `enable_ticket_creation`:

1. `credentials.yml.enc` → `tdx.production.enable_ticket_creation: 'true'`
2. `credentials.yml.enc` → `tdx.enable_ticket_creation: 'false'`
3. `ENV['TDX_ENABLE_TICKET_CREATION']` → `true`
4. Default: `false`

Result: `true` (from credentials – environment variables are only used when no credential is set).

Note: Store credential toggles as strings `'true'` or `'false'` to ensure correct detection.

## 🐛 Debug Logging

### TDX API Request Logging

The gem now includes detailed logging of TDX API requests for debugging:

```
TDX API Request - App ID: 46
TDX API Request - Payload: {
  "TypeID": 12,
  "FormID": 107,
  "ServiceOfferingID": 29,
  "StatusID": 115,
  "SourceID": 8,
  "ServiceID": 2345,
  "ResponsibleGroupID": 631,
  "Title": "[MyApp Feedback] User feedback message",
  "Description": "User feedback message\n--- Context ---\nAdditional context",
  "IsRichHtml": false,
  "RequestorEmail": "user@example.com",
  "AccountID": 2
}
```

### Configuration Resolution Logging

The gem logs when credentials are resolved:

```
TDX Feedback Gem: Resolved enable_ticket_creation=true from credentials/ENV
TDX Feedback Gem: Resolved account_id=2 from credentials/ENV
```

## 🧪 Testing Configuration

### Test Configuration

```ruby
# spec/spec_helper.rb or test/test_helper.rb
TdxFeedbackGem.configure do |config|
  config.enable_ticket_creation = true
  config.tdx_base_url = 'https://test-api.example.com'
  config.oauth_token_url = 'https://test-api.example.com/oauth/token'
  config.client_id = 'test_client_id'
  config.client_secret = 'test_client_secret'
  config.app_id = 31
  config.type_id = 12
  config.status_id = 112
  config.source_id = 8
  config.service_id = 67
  config.responsible_group_id = 631
end
```

### Environment-Specific Test Configs

```ruby
# config/environments/test.rb
config.tdx_feedback_gem = {
  enable_ticket_creation: false,
  log_level: :debug
}
```

## 🔍 Configuration Validation

### Check Current Configuration

```ruby
# In Rails console
TdxFeedbackGem.configuration.app_id
TdxFeedbackGem.configuration.enable_ticket_creation
TdxFeedbackGem.configuration.tdx_base_url
```

<!-- Validation helper method is not provided; trigger a test ticket in a non-production environment instead. -->

## 🚨 Common Configuration Issues

### Issue: Credentials Not Loading

**Symptoms:**

- Configuration values are `nil`
- TDX API calls fail with authentication errors

**Solutions:**

- Verify `master.key` is present and correct
- Check credentials file syntax
- Ensure environment is set correctly

### Issue: Environment Variables Not Working

**Symptoms:**

- Configuration values don't match environment variables
- Changes don't take effect after restart

**Solutions:**

- Verify variable names (must start with `TDX_`)
- Restart the application after setting variables
- Check for typos in variable names

### Issue: Configuration Conflicts

**Symptoms:**

- Unexpected configuration values
- Inconsistent behavior across environments

**Solutions:**

- Review configuration priority order
- Check for conflicting values in different sources
- Use `rails console` to inspect current configuration

## 🔄 Next Steps

Now that you understand configuration:

1. **[Integration Examples](Integration-Examples.md)** - See configuration in action
2. **[Styling and Theming](Styling-and-Theming.md)** - Customize the appearance
3. **[Testing Guide](Testing)** - Test your configuration
4. **[Production Deployment](Production-Deployment.md)** - Deploy with confidence

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting.md)
- Review [Getting Started](Getting-Started.md) for basic setup
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

_For advanced configuration options, see the [Advanced Customization](Advanced-Customization.md) guide._
