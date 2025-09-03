# Configuration Guide

Complete guide to configuring the TDX Feedback Gem for your Rails application.


## 📋 Configuration Overview

The gem uses a hierarchical configuration system that automatically resolves values from multiple sources:

1. **Rails Encrypted Credentials** (highest priority – recommended for production)
2. **Environment Variables** (medium priority – good for deployment)
3. **Built-in Defaults** (lowest priority – fallback values)

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
config.tdx_base_url = 'https://gw.api.it.umich.edu/um/it'
config.oauth_token_url = 'https://gw.api.it.umich.edu/um/oauth2/token'
```

**Default URLs:**

- **Development/Test**: `https://gw-test.api.it.umich.edu/um/it`
- **Production**: `https://gw.api.it.umich.edu/um/it`

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
```

## 🎨 Customization Options

### Ticket Appearance

```ruby
config.title_prefix = '[Feedback]'    # Prefix for ticket titles
config.default_requestor_email = 'noreply@example.com'  # Fallback email
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
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
  enable_ticket_creation: 'false'  # Use string 'true'/'false'
  staging:
    client_id: staging_client_id_here
    client_secret: staging_client_secret_here
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
  enable_ticket_creation: 'true'   # Use string 'true'/'false'
  production:
    client_id: prod_client_id_here
    client_secret: prod_client_secret_here
    base_url: https://gw.api.it.umich.edu/um/it
    oauth_token_url: https://gw.api.it.umich.edu/um/oauth2/token
  enable_ticket_creation: 'true'   # Use string 'true'/'false'
```

#### Shared Credentials with Environment-Specific URLs

```yaml
# Global TDX credentials (same for all environments)
tdx_client_id: your_shared_client_id_here
tdx_client_secret: your_shared_client_secret_here

# Environment-specific URLs only
tdx:
  development:
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
  enable_ticket_creation: 'false'  # Use string 'true'/'false'
  staging:
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
  enable_ticket_creation: 'true'
  production:
    base_url: https://gw.api.it.umich.edu/um/it
    oauth_token_url: https://gw.api.it.umich.edu/um/oauth2/token
  enable_ticket_creation: 'true'
```

### Environment Variables

#### Single Environment Configuration

```bash
# .env or your environment configuration
TDX_CLIENT_ID=your_client_id_here
TDX_CLIENT_SECRET=your_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=false
```

#### Environment-Specific .env Files

```bash
# .env.development
TDX_CLIENT_ID=dev_client_id_here
TDX_CLIENT_SECRET=dev_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=false

# .env.staging
TDX_CLIENT_ID=staging_client_id_here
TDX_CLIENT_SECRET=staging_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=true

# .env.production
TDX_CLIENT_ID=prod_client_id_here
TDX_CLIENT_SECRET=prod_client_secret_here
TDX_BASE_URL=https://gw.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw.api.it.umich.edu/um/oauth2/token
TDX_ENABLE_TICKET_CREATION=true
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
| `TDX_BASE_URL` | `https://gw.api.it.umich.edu/um/it` | Production TDX API URL |
| `TDX_OAUTH_TOKEN_URL` | `https://gw.api.it.umich.edu/um/oauth2/token` | Production OAuth token URL |

#### Development/Staging Variables

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `TDX_BASE_URL` | `https://gw-test.api.it.umich.edu/um/it` | Test TDX API URL |
| `TDX_OAUTH_TOKEN_URL` | `https://gw-test.api.it.umich.edu/um/oauth2/token` | Test OAuth token URL |

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
  - TDX_BASE_URL=https://gw.api.it.umich.edu/um/it
  - TDX_OAUTH_TOKEN_URL=https://gw.api.it.umich.edu/um/oauth2/token
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
```

### Heroku

```bash
heroku config:set TDX_ENABLE_TICKET_CREATION=true
heroku config:set TDX_CLIENT_ID=your_client_id
heroku config:set TDX_CLIENT_SECRET=your_client_secret
heroku config:set TDX_BASE_URL=https://gw.api.it.umich.edu/um/it
heroku config:set TDX_OAUTH_TOKEN_URL=https://gw.api.it.umich.edu/um/oauth2/token
```

## 🔄 Configuration Resolution Priority

### Priority Order

1. **Rails Encrypted Credentials** (highest priority)
   - Environment-specific credentials first (e.g., `tdx.production.client_id`)
   - Then global credentials (e.g., `tdx.client_id`)
2. **Environment Variables** (medium priority)
   - `TDX_CLIENT_ID`, `TDX_ENABLE_TICKET_CREATION`, etc.
3. **Built-in Defaults** (lowest priority)
   - Development: `https://gw-test.api.it.umich.edu/um/it`
   - Production: `https://gw.api.it.umich.edu/um/it`

### Example Resolution

For `enable_ticket_creation`:

1. `credentials.yml.enc` → `tdx.production.enable_ticket_creation: 'true'`
2. `credentials.yml.enc` → `tdx.enable_ticket_creation: 'false'`
3. `ENV['TDX_ENABLE_TICKET_CREATION']` → `true`
4. Default: `false`

Result: `true` (from credentials – environment variables are only used when no credential is set).

Note: Store credential toggles as strings `'true'` or `'false'` to ensure correct detection.

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
  config.app_id = 123
  config.type_id = 456
  config.status_id = 112
  config.source_id = 131
  config.service_id = 415
  config.responsible_group_id = 161
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

1. **[Integration Examples](Integration-Examples)** - See configuration in action
2. **[Styling and Theming](Styling-and-Theming)** - Customize the appearance
3. **[Testing Guide](Testing)** - Test your configuration
4. **[Production Deployment](Production-Deployment)** - Deploy with confidence

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Getting Started](Getting-Started) for basic setup
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

_For advanced configuration options, see the [Advanced Customization](Advanced-Customization) guide._
