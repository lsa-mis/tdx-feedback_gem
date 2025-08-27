# Troubleshooting Guide

Complete guide to solving common issues with the TDX Feedback Gem.

## 🚨 Common Issues

### Modal Not Opening

**Symptoms**:
- Clicking feedback link/button does nothing
- No modal appears
- JavaScript errors in browser console

**Possible Causes**:
- JavaScript not loading
- CSS conflicts
- Stimulus not initialized
- Asset compilation issues

**Solutions**:

#### 1. Check JavaScript Loading

```bash
# Verify assets are precompiled
bundle exec rails assets:precompile

# Check if JavaScript is included in layout
# Should see: tdx_feedback_gem.js
```

#### 2. Check Stimulus Setup

```javascript
// In browser console, verify Stimulus is loaded
console.log(window.Stimulus);

// Check if controller is registered
console.log(window.Stimulus.application.controllers);
```

#### 3. Check for JavaScript Errors

```javascript
// Open browser console and look for errors
// Common issues:
// - jQuery not loaded (Rails 5)
// - Stimulus not loaded
// - Asset path issues
```

#### 4. Verify Asset Pipeline

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Ensure assets are included
    config.assets.precompile += %w( tdx_feedback_gem.js tdx_feedback_gem.css )
  end
end
```

### Form Not Submitting

**Symptoms**:
- Form appears but submission fails
- No response after clicking submit
- Error messages not displayed

**Possible Causes**:
- CSRF token issues
- Database connection problems
- Validation errors
- Route configuration issues

**Solutions**:

#### 1. Check CSRF Token

```erb
<!-- Ensure CSRF meta tags are present -->
<%= csrf_meta_tags %>
<%= csp_meta_tag %>
```

```javascript
// Verify CSRF token is being sent
// Check Network tab in browser dev tools
// Should see X-CSRF-Token header
```

#### 2. Check Database Connection

```bash
# Test database connection
rails console
```

```ruby
# In Rails console
ActiveRecord::Base.connection.execute("SELECT 1")
# Should return result, not error
```

#### 3. Check Routes

```bash
# Verify routes are registered
rails routes | grep tdx_feedback
```

Expected output:
```
tdx_feedback_gem_feedback GET    /tdx_feedback_gem/feedbacks/new(.:format)  tdx_feedback_gem/feedbacks#new
                         POST   /tdx_feedback_gem/feedbacks(.:format)      tdx_feedback_gem/feedbacks#create
```

#### 4. Check Validation Errors

```ruby
# In Rails console, test model validation
feedback = TdxFeedbackGem::Feedback.new
feedback.valid?
feedback.errors.full_messages
```

### TDX Integration Not Working

**Symptoms**:
- Feedback stored locally but no TDX tickets created
- TDX API errors in logs
- Authentication failures

**Possible Causes**:
- Invalid credentials
- Network connectivity issues
- Configuration errors
- API endpoint issues

**Solutions**:

#### 1. Verify TDX Credentials

```ruby
# Check configuration in Rails console
TdxFeedbackGem.configuration.client_id
TdxFeedbackGem.configuration.client_secret
TdxFeedbackGem.configuration.tdx_base_url
TdxFeedbackGem.configuration.enable_ticket_creation
```

#### 2. Test TDX API Connection

```ruby
# Test API connection manually
require 'net/http'
require 'uri'

uri = URI('https://gw.api.it.umich.edu/um/oauth2/token')
response = Net::HTTP.get_response(uri)
puts response.code
puts response.body
```

#### 3. Check Network Access

```bash
# Test network connectivity
curl -v https://gw.api.it.umich.edu/um/oauth2/token

# Check firewall/proxy settings
# Ensure outbound HTTPS (443) is allowed
```

#### 4. Verify OAuth Flow

```bash
# Test OAuth token request
curl -X POST "https://gw.api.it.umich.edu/um/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(echo -n 'client_id:client_secret' | base64)" \
  -d "grant_type=client_credentials&scope=tdxticket"
```

### Configuration Issues

**Symptoms**:
- Configuration values are `nil`
- Unexpected behavior
- Environment-specific issues

**Possible Causes**:
- Credentials not loaded
- Environment variables not set
- Configuration priority conflicts

**Solutions**:

#### 1. Check Credentials Loading

```bash
# Verify master.key exists
ls -la config/master.key

# Test credentials access
rails console
```

```ruby
# In Rails console
Rails.application.credentials.tdx
# Should return hash, not nil
```

#### 2. Check Environment Variables

```bash
# Verify environment variables are set
echo $TDX_CLIENT_ID
echo $TDX_CLIENT_SECRET
echo $TDX_ENABLE_TICKET_CREATION
```

#### 3. Check Configuration Priority

```ruby
# In Rails console, check configuration resolution
TdxFeedbackGem.configuration.client_id
TdxFeedbackGem.configuration.enable_ticket_creation

# Configuration should resolve from:
# 1. Rails credentials (highest)
# 2. Environment variables (medium)
# 3. Built-in defaults (lowest)
```

## 🔍 Debug Mode

### Enable Debug Logging

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.log_level = :debug  # Enable debug logging

  # ... other configuration
end
```

### View Debug Information

```ruby
# In Rails console
TdxFeedbackGem.configuration.inspect

# Check logs for detailed information
tail -f log/development.log
```

### Browser Debug Tools

```javascript
// Enable debug mode in browser
localStorage.setItem('tdx_feedback_debug', 'true');

// Refresh page to see debug information
// Check console for detailed logs
```

## 🚨 Error Messages

### Common Error Codes

#### 401 Unauthorized

**Meaning**: Authentication failed

**Possible Causes**:
- Invalid client_id/client_secret
- Expired OAuth token
- Incorrect OAuth scope

**Solutions**:
```ruby
# Verify credentials
TdxFeedbackGem.configuration.client_id
TdxFeedbackGem.configuration.client_secret

# Check OAuth scope
TdxFeedbackGem.configuration.oauth_scope
# Should be 'tdxticket'
```

#### 403 Forbidden

**Meaning**: Insufficient permissions

**Possible Causes**:
- Client doesn't have permission to create tickets
- Invalid app_id or service_id
- Account restrictions

**Solutions**:
```ruby
# Verify TDX configuration values
TdxFeedbackGem.configuration.app_id
TdxFeedbackGem.configuration.service_id

# Contact TDX administrator to verify permissions
```

#### 422 Unprocessable Entity

**Meaning**: Validation failed

**Possible Causes**:
- Missing required fields
- Invalid field values
- Field type mismatches

**Solutions**:
```ruby
# Check required fields
TdxFeedbackGem.configuration.app_id
TdxFeedbackGem.configuration.type_id
TdxFeedbackGem.configuration.status_id
TdxFeedbackGem.configuration.source_id
TdxFeedbackGem.configuration.service_id
TdxFeedbackGem.configuration.responsible_group_id

# Verify values exist in TDX system
```

#### 429 Too Many Requests

**Meaning**: Rate limit exceeded

**Possible Causes**:
- Too many API requests
- OAuth token requests exceeded limit

**Solutions**:
```ruby
# Implement exponential backoff
def handle_rate_limit(response)
  if response.code == 429
    retry_after = response.headers['Retry-After'].to_i
    sleep(retry_after)
    retry
  end
end

# Reduce request frequency
# Cache OAuth tokens appropriately
```

### Error Response Format

```json
{
  "error": "Error message",
  "details": [
    "Detailed error 1",
    "Detailed error 2"
  ],
  "requestId": "req-12345",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 🔧 Diagnostic Commands

### Rails Console Commands

```ruby
# Check gem configuration
TdxFeedbackGem.configuration.inspect

# Test TDX client
client = TdxFeedbackGem::Client.new
client.test_connection

# Check feedback records
TdxFeedbackGem::Feedback.count
TdxFeedbackGem::Feedback.last

# Verify routes
Rails.application.routes.routes.map(&:path).grep(/tdx_feedback/)
```

### Database Commands

```bash
# Check if table exists
rails dbconsole
\dt *tdx_feedback*

# Check table structure
\d tdx_feedback_gem_feedbacks

# Check for data
SELECT COUNT(*) FROM tdx_feedback_gem_feedbacks;
SELECT * FROM tdx_feedback_gem_feedbacks LIMIT 5;
```

### Asset Commands

```bash
# Check asset compilation
bundle exec rails assets:precompile

# Check asset manifest
cat public/assets/manifest.json | grep tdx_feedback

# Verify assets exist
ls -la public/assets/tdx_feedback_gem*
```

## 🐛 Common Scenarios

### Development Environment Issues

#### Issue: Modal works locally but not in development

**Solutions**:
```ruby
# Check environment configuration
# config/environments/development.rb
config.assets.debug = true
config.assets.compile = true

# Ensure assets are loaded
config.assets.precompile += %w( tdx_feedback_gem.js tdx_feedback_gem.css )
```

#### Issue: TDX disabled in development

**Solutions**:
```ruby
# Enable TDX for testing
TdxFeedbackGem.configure do |config|
  config.enable_ticket_creation = true
end

# Or use environment variable
export TDX_ENABLE_TICKET_CREATION=true
```

### Production Environment Issues

#### Issue: Assets not loading in production

**Solutions**:
```bash
# Precompile assets
bundle exec rails assets:precompile

# Check asset manifest
cat public/assets/manifest.json

# Verify asset paths in HTML
# Should see: /assets/tdx_feedback_gem-{hash}.js
```

#### Issue: TDX integration failing in production

**Solutions**:
```ruby
# Check production credentials
Rails.application.credentials.production.tdx

# Verify environment variables
ENV['TDX_CLIENT_ID']
ENV['TDX_CLIENT_SECRET']

# Check network connectivity
# Ensure outbound HTTPS is allowed
```

### Docker/Kubernetes Issues

#### Issue: Configuration not loading in container

**Solutions**:
```yaml
# docker-compose.yml
environment:
  - RAILS_ENV=production
  - TDX_ENABLE_TICKET_CREATION=true
  - TDX_CLIENT_ID=${TDX_CLIENT_ID}
  - TDX_CLIENT_SECRET=${TDX_CLIENT_SECRET}
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
```

## 📞 Getting Help

### Before Asking for Help

1. **Check this troubleshooting guide**
2. **Enable debug logging**
3. **Check browser console for errors**
4. **Verify configuration values**
5. **Test TDX API connection manually**

### Information to Provide

When reporting an issue, include:

- **Rails version**: `rails -v`
- **Ruby version**: `ruby -v`
- **Gem version**: Check Gemfile.lock
- **Environment**: development, staging, production
- **Error messages**: Full error text and stack trace
- **Configuration**: Relevant config values (without secrets)
- **Steps to reproduce**: Clear steps to trigger the issue

### Support Channels

- **[GitHub Issues](https://github.com/lsa-mis/tdx-feedback_gem/issues)** - Bug reports and feature requests
- **[GitHub Discussions](https://github.com/lsa-mis/tdx-feedback_gem/discussions)** - Questions and community help
- **Documentation**: Check other wiki pages for related information

## 🔄 Next Steps

Now that you've troubleshooted your issue:

1. **[Configuration Guide](Configuration-Guide)** - Review configuration if needed
2. **[Testing Guide](Testing)** - Test your fix
3. **[Performance Optimization](Performance-Optimization)** - Optimize after fixing
4. **[Production Deployment](Production-Deployment)** - Deploy with confidence

## 🆘 Still Having Issues?

- Check the [Configuration Guide](Configuration-Guide) for setup details
- Review [Getting Started](Getting-Started) for basic setup
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub with detailed information

---

*For more specific troubleshooting, check the relevant wiki pages for your issue type.*
