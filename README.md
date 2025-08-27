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

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tdx_feedback_gem', git: 'https://github.com/lsa-mis/tdx-feedback_gem.git'
```

And then execute:

```bash
$ bundle install
```

## Installation & Configuration

Install the gem and run the generator:

```bash
$ bundle install
$ rails generate tdx_feedback_gem:install
```

This creates:

- `config/initializers/tdx_feedback_gem.rb` - Configuration file
- `db/migrate/[timestamp]_create_tdx_feedback_gem_feedbacks.rb` - Database migration

Run the migration:

```bash
$ rails db:migrate
```

### Configuration

The generator creates a comprehensive configuration file at `config/initializers/tdx_feedback_gem.rb`:

**Runtime Toggle (No Redeploy Required):**

You can enable/disable TDX ticket creation at runtime using an environment variable:

```bash
# Enable TDX ticket creation
export TDX_ENABLE_TICKET_CREATION=true

# Disable TDX ticket creation
export TDX_ENABLE_TICKET_CREATION=false
```

This is perfect for:
- Toggling during incidents or maintenance
- Testing in different environments
- Container orchestration (Docker, Kubernetes)
- DevOps/SRE team control without developer involvement

```ruby
TdxFeedbackGem.configure do |config|
  # === Authentication ===
  # Require authenticated user (expects current_user method)
  config.require_authentication = false

  # === TDX API Integration ===
  # Enable automatic ticket creation via TDX API
  config.enable_ticket_creation = false

  # TDX API base URL and OAuth endpoints
  # These are automatically resolved from Rails credentials or environment variables
  # No manual configuration needed unless you want to override defaults

  # OAuth2 client credentials
  # These are automatically resolved from Rails credentials or environment variables
  # No manual configuration needed unless you want to override
  config.oauth_scope = 'tdxticket'

  # === Ticket Configuration ===
  # Required TDX ticket fields (get these from your TDX admin)
  config.app_id = 31                    # Application ID
  config.type_id = 12                   # Ticket type ID
  config.status_id = 77                 # Initial status ID
  config.source_id = 8                  # Ticket source ID
  config.service_id = 67                # Service ID
  config.responsible_group_id = 631     # Responsible group ID

  # === Customization ===
  config.title_prefix = '[Feedback]'    # Prefix for ticket titles
  config.default_requestor_email = 'noreply@example.com'  # Fallback email
end
```

#### Configuration Values (Recommended: Rails Credentials)

The gem automatically resolves sensitive configuration values from Rails encrypted credentials with fallback to environment variables. This provides better security than plain environment variables.

**Setup Rails Credentials:**

```bash
# Edit credentials (creates credentials.yml.enc and master.key)
bin/rails credentials:edit
```

**Add to credentials.yml.enc:**

```yaml
# Environment-specific TDX configuration (recommended for different credentials per environment)
tdx:
  development:
    client_id: dev_client_id_here
    client_secret: dev_client_secret_here
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
    enable_ticket_creation: false  # Disable in development
  staging:
    client_id: staging_client_id_here
    client_secret: staging_client_secret_here
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
    enable_ticket_creation: true   # Enable in staging for testing
  production:
    client_id: prod_client_id_here
    client_secret: prod_client_secret_here
    base_url: https://gw.api.it.umich.edu/um/it
    oauth_token_url: https://gw.api.it.umich.edu/um/oauth2/token
    enable_ticket_creation: true   # Enable in production
```

**Or for shared credentials with environment-specific URLs:**

```yaml
# Global TDX credentials (same for all environments)
tdx_client_id: your_shared_client_id_here
tdx_client_secret: your_shared_client_secret_here

# Environment-specific URLs only
tdx:
  development:
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
    enable_ticket_creation: false
  staging:
    base_url: https://gw-test.api.it.umich.edu/um/it
    oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
    enable_ticket_creation: true
  production:
    base_url: https://gw.api.it.umich.edu/um/it
    oauth_token_url: https://gw.api.it.umich.edu/um/oauth2/token
    enable_ticket_creation: true
```

**Overriding Credentials with Environment Variables:**

Sometimes you need to override a credential value temporarily. Environment variables allow this:

```bash
# Even if credentials.yml.enc has enable_ticket_creation: true
# This will temporarily disable it:
export TDX_ENABLE_TICKET_CREATION=false

# Or temporarily change the base URL:
export TDX_BASE_URL=https://emergency-api.example.com/um/it
```

This is perfect for:
- Incident response (quickly disable TDX)
- Testing different configurations
- Emergency maintenance windows

**Or for global configuration (not recommended for production):**

```yaml
# Global TDX configuration (same for all environments)
tdx_client_id: your_client_id_here
tdx_client_secret: your_client_secret_here
tdx:
  base_url: https://gw-test.api.it.umich.edu/um/it
  oauth_token_url: https://gw-test.api.it.umich.edu/um/oauth2/token
```

#### Environment Variables (Fallback)

If you prefer environment variables or need them for certain deployment scenarios, the gem will automatically fall back to these values:

**For single environment or global configuration:**

```bash
# .env or your environment configuration
TDX_CLIENT_ID=your_client_id_here
TDX_CLIENT_SECRET=your_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token
```

**For environment-specific configuration, you can use different .env files:**

**Runtime TDX Toggle Examples:**

```bash
# Docker/Kubernetes deployment
docker run -e TDX_ENABLE_TICKET_CREATION=true your-app

# Kubernetes deployment.yaml
env:
- name: TDX_ENABLE_TICKET_CREATION
  value: "true"

# Heroku
heroku config:set TDX_ENABLE_TICKET_CREATION=true

# Local development
export TDX_ENABLE_TICKET_CREATION=true
rails server

# Production server (temporary disable during incident)
export TDX_ENABLE_TICKET_CREATION=false
# Restart application or reload configuration
```

### Hatchbox.io Environment Variables

Hatchbox.io provides a user-friendly interface for managing environment variables. Here's how to configure the TDX Feedback Gem:

#### **1. Access Environment Variables**
1. Log into your Hatchbox.io dashboard
2. Navigate to your application
3. Click on **"Environment Variables"** in the left sidebar

#### **2. Required TDX Configuration Variables**
Add these variables to enable TDX integration:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `TDX_ENABLE_TICKET_CREATION` | `true` | Enable TDX ticket creation |
| `TDX_CLIENT_ID` | `your_client_id` | TDX OAuth client ID |
| `TDX_CLIENT_SECRET` | `your_client_secret` | TDX OAuth client secret |
| `TDX_BASE_URL` | `https://gw.api.it.umich.edu/um/it` | Production TDX API URL |
| `TDX_OAUTH_TOKEN_URL` | `https://gw.api.it.umich.edu/um/oauth2/token` | Production OAuth token URL |

#### **3. Development/Staging Variables**
For non-production environments, use the test URLs:

| Variable Name | Value | Description |
|---------------|-------|-------------|
| `TDX_BASE_URL` | `https://gw-test.api.it.umich.edu/um/it` | Test TDX API URL |
| `TDX_OAUTH_TOKEN_URL` | `https://gw-test.api.it.umich.edu/um/oauth2/token` | Test OAuth token URL |

#### **4. Quick Toggle for Incidents**
To temporarily disable TDX integration during incidents:
1. Go to **Environment Variables**
2. Change `TDX_ENABLE_TICKET_CREATION` from `true` to `false`
3. Click **"Save"**
4. Your application will automatically restart with the new setting

#### **5. Environment Variable Priority**
Hatchbox.io environment variables have **medium priority** in the configuration hierarchy:

**Priority Order:**
1. **Rails Encrypted Credentials** (highest - set in `credentials.yml.enc`)
2. **Hatchbox.io Environment Variables** (medium - set in dashboard)
3. **Built-in Defaults** (lowest - hardcoded in gem)

**Important:** If you set a value in `credentials.yml.enc`, it will override the same setting in Hatchbox.io environment variables. This allows you to:
- Use credentials for sensitive production values
- Use Hatchbox.io for runtime toggles and non-sensitive settings
- Override credentials when needed by setting environment variables

```bash
# .env.development
TDX_CLIENT_ID=dev_client_id_here
TDX_CLIENT_SECRET=dev_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token

# .env.staging
TDX_CLIENT_ID=staging_client_id_here
TDX_CLIENT_SECRET=staging_client_secret_here
TDX_BASE_URL=https://gw-test.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw-test.api.it.umich.edu/um/oauth2/token

# .env.production
TDX_CLIENT_ID=prod_client_id_here
TDX_CLIENT_SECRET=prod_client_secret_here
TDX_BASE_URL=https://gw.api.it.umich.edu/um/it
TDX_OAUTH_TOKEN_URL=https://gw.api.it.umich.edu/um/oauth2/token
```

**Configuration Resolution Priority (All Variables):**

All TDX configuration variables follow this hierarchy:

1. **Rails Encrypted Credentials** (highest priority)
   - Environment-specific credentials first (e.g., `tdx.production.client_id`)
   - Then global credentials (e.g., `tdx.client_id`)
2. **Environment Variables** (medium priority)
   - `TDX_CLIENT_ID`, `TDX_ENABLE_TICKET_CREATION`, etc.
3. **Built-in Defaults** (lowest priority)
   - Development: `https://gw-test.api.it.umich.edu/um/it`
   - Production: `https://gw.api.it.umich.edu/um/it`

**Example for `enable_ticket_creation`:**
1. `credentials.yml.enc` → `tdx.production.enable_ticket_creation: true`
2. `credentials.yml.enc` → `tdx.enable_ticket_creation: false`
3. `ENV['TDX_ENABLE_TICKET_CREATION']` → `true`
4. Default: `false`

## Usage

### Basic Integration

The gem provides several helper methods for easy integration:

#### 1. Simple Feedback Link (Recommended for footers)

```erb
<!-- In your application layout or any view -->
<%= feedback_footer_link %>
```

#### 2. Feedback Button (Good for headers or prominent placement)

```erb
<%= feedback_header_button %>
```

#### 3. Custom Feedback Link

```erb
<%= feedback_link('Report Issue', class: 'custom-feedback-link') %>
```

#### 4. Feedback Icon

```erb
<%= feedback_icon(class: 'header-icon') %>
```

#### 5. Complete Feedback System

```erb
<%= feedback_system(trigger: :button, text: 'Send Feedback', class: 'btn-primary') %>
```

#### 6. Stimulus-Powered Trigger (Advanced)

```erb
<%= feedback_trigger(type: :button, text: 'Feedback', class: 'btn-primary') %>
```

### User Experience Flow

1. **User is on any page** of your application
2. **User clicks feedback link/button** → Modal opens
3. **User fills out feedback form** → Stays on same page
4. **User submits feedback** → Form sends to TDX API via AJAX
5. **Success response** → Modal closes, user continues where they were
6. **No page navigation** → Seamless experience

## Styling & Theming

The gem includes comprehensive CSS that you can override to match your application's design.

### CSS Classes Reference

#### Modal Structure

```css
.tdx-feedback-modal              /* Modal container (fixed positioning) */
.tdx-feedback-modal-overlay      /* Backdrop overlay */
.tdx-feedback-modal-content      /* Modal content box */
.tdx-feedback-modal-header       /* Modal header with title and close button */
.tdx-feedback-modal-body         /* Modal body containing the form */
.tdx-feedback-modal-close        /* Close button (×) */
```

#### Form Elements

```css
.tdx-feedback-form              /* Main form element */
.tdx-feedback-field             /* Form field wrapper */
.tdx-feedback-label             /* Field labels */
.tdx-feedback-textarea          /* Message textarea */
.tdx-feedback-input             /* Context input field */
.tdx-feedback-actions           /* Button container */
.tdx-feedback-cancel            /* Cancel button */
.tdx-feedback-submit            /* Submit button */
```

#### States & Messages

```css
.tdx-feedback-modal-open        /* Applied when modal is visible */
.tdx-feedback-errors            /* Error message container */
.tdx-feedback-message           /* Success/error message container */
.tdx-feedback-message-success   /* Success message styling */
.tdx-feedback-message-error     /* Error message styling */
```

#### Link & Button Styles

```css
.tdx-feedback-link              /* Feedback links */
.tdx-feedback-button            /* Feedback buttons */
.tdx-feedback-icon              /* Icon links */
.tdx-feedback-footer-link       /* Footer-specific styling */
.tdx-feedback-header-button     /* Header-specific styling */
```

### Customization Examples

#### Complete Theme Override

```css
/* Dark theme example */
.tdx-feedback-modal-content {
  background: #1f2937;
  color: #f9fafb;
  border-radius: 12px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.4);
}

.tdx-feedback-modal-header {
  border-bottom-color: #374151;
}

.tdx-feedback-modal-header h3 {
  color: #f9fafb;
}

.tdx-feedback-input,
.tdx-feedback-textarea {
  background: #111827;
  border-color: #374151;
  color: #f9fafb;
}

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.tdx-feedback-input::placeholder,
.tdx-feedback-textarea::placeholder {
  color: #9ca3af;
}

.tdx-feedback-submit {
  background: #3b82f6;
  color: white;
}

.tdx-feedback-submit:hover:not(:disabled) {
  background: #2563eb;
}

.tdx-feedback-cancel {
  background: #374151;
  color: #f9fafb;
}
```

#### Gradient Theme

```css
/* Gradient background theme */
.tdx-feedback-modal-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.tdx-feedback-modal-header h3 {
  color: white;
}

.tdx-feedback-input,
.tdx-feedback-textarea {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.3);
  color: white;
}

.tdx-feedback-input::placeholder,
.tdx-feedback-textarea::placeholder {
  color: rgba(255, 255, 255, 0.7);
}
```

#### Minimal Theme

```css
/* Minimal, borderless design */
.tdx-feedback-modal-content {
  background: white;
  border: 1px solid #e5e7eb;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.tdx-feedback-input,
.tdx-feedback-textarea {
  border: none;
  border-bottom: 1px solid #e5e7eb;
  border-radius: 0;
  background: transparent;
}

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  border-bottom-color: #3b82f6;
  box-shadow: none;
}
```

### Responsive Design

The modal is fully responsive with mobile-specific styles:

```css
@media (max-width: 640px) {
  .tdx-feedback-modal-content {
    width: 95%;
    margin: 20px;
    max-height: calc(100vh - 40px);
  }

  .tdx-feedback-actions {
    flex-direction: column; /* Buttons stack vertically on mobile */
  }
}
```

### Custom Button Styles

```css
/* Custom feedback button styles */
.tdx-feedback-link {
  color: #6b7280;
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 6px;
  transition: all 0.2s;
}

.tdx-feedback-link:hover {
  color: #3b82f6;
  background: #f3f4f6;
}

.tdx-feedback-button {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s;
}

.tdx-feedback-button:hover {
  background: #e5e7eb;
  border-color: #9ca3af;
}
```

### Icon Customization

The feedback icon uses an embedded SVG that you can customize:

```css
.tdx-feedback-icon-svg {
  width: 24px;
  height: 24px;
  fill: currentColor;
}

/* Custom icon color */
.tdx-feedback-icon {
  color: #3b82f6;
}

.tdx-feedback-icon:hover {
  color: #2563eb;
}
```

## Stimulus Integration

The gem provides a complete Stimulus controller for modal management and form submission.

### Global Function

You can open the feedback modal programmatically from anywhere in your JavaScript:

```javascript
// Open feedback modal from any JavaScript code
window.openTdxFeedbackModal();
```

### Modal Events

Listen to modal lifecycle events for custom behavior:

```javascript
// Modal opened event
document.addEventListener('tdx-feedback:opened', function(event) {
  console.log('Feedback modal opened');
  // Track analytics, show notifications, etc.
});

// Modal closed event
document.addEventListener('tdx-feedback:closed', function(event) {
  console.log('Feedback modal closed');
  // Track analytics, cleanup, etc.
});
```

### Extending the Stimulus Controller

Create a custom controller to extend the default behavior:

```javascript
// app/javascript/controllers/custom_feedback_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger"]

  openFeedback() {
    // Custom analytics tracking
    if (window.gtag) {
      gtag('event', 'feedback_modal_opened', {
        'event_category': 'engagement',
        'event_label': 'feedback_button'
      });
    }

    // Open the feedback modal
    window.openTdxFeedbackModal();
  }
}
```

Then use it in your views:

```erb
<%= feedback_trigger(
  type: :button,
  text: 'Send Feedback',
  class: 'btn-primary',
  data: {
    controller: 'custom-feedback',
    action: 'click->custom-feedback#openFeedback'
  }
) %>
```

### Advanced Stimulus Customization

For more advanced customization, you can create your own Stimulus controller that interacts with the feedback system:

```javascript
// app/javascript/controllers/advanced_feedback_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Listen for feedback modal events
    document.addEventListener('tdx-feedback:opened', this.onModalOpened.bind(this))
    document.addEventListener('tdx-feedback:closed', this.onModalClosed.bind(this))
  }

  disconnect() {
    document.removeEventListener('tdx-feedback:opened', this.onModalOpened.bind(this))
    document.removeEventListener('tdx-feedback:closed', this.onModalClosed.bind(this))
  }

  onModalOpened(event) {
    // Modal was opened - add custom behavior
    console.log('Feedback modal is now open')
    // Maybe pause videos, hide other modals, etc.
  }

  onModalClosed(event) {
    // Modal was closed - cleanup or follow-up actions
    console.log('Feedback modal was closed')
    // Maybe show a thank you message, redirect, etc.
  }

  openWithContext(context) {
    // Store context for analytics
    sessionStorage.setItem('feedback_context', context)
    window.openTdxFeedbackModal()
  }
}
```

#### Pre-filling Context

You can programmatically add context to the feedback:

```javascript
// Set context before opening
sessionStorage.setItem('feedback_context', 'User was on page: ' + window.location.href)
window.openTdxFeedbackModal()
```

The context will be automatically included in the feedback submission.

## Database Schema

The gem creates a `tdx_feedback_gem_feedbacks` table with the following structure:

```ruby
create_table :tdx_feedback_gem_feedbacks do |t|
  t.text :message, null: false          # Required feedback message
  t.text :context                       # Optional additional context
  t.timestamps                          # created_at, updated_at
end

add_index :tdx_feedback_gem_feedbacks, :created_at
```

### Model Validation

- `message`: Required, no length limit
- `context`: Optional, maximum 10,000 characters

## API Endpoints

The gem provides these JSON endpoints:

- `GET /tdx_feedback_gem/feedbacks/new` - Returns modal HTML content
- `POST /tdx_feedback_gem/feedbacks` - Creates a new feedback record

### Request/Response Examples

#### GET /tdx_feedback_gem/feedbacks/new

Returns the modal HTML for the feedback form.

**Response:**

```json
{
  "html": "<div class=\"tdx-feedback-modal\"...>...</div>"
}
```

#### POST /tdx_feedback_gem/feedbacks

Creates a feedback record and optionally a TDX ticket.

**Request:**

```json
{
  "feedback": {
    "message": "User feedback message",
    "context": "Optional additional context"
  }
}
```

**Success Response:**

```json
{
  "success": true,
  "message": "Thank you for your feedback. A support ticket has been created.",
  "feedback_id": 123,
  "ticket_id": "TDX-456"
}
```

**Error Response:**

```json
{
  "success": false,
  "errors": ["Message can't be blank"],
  "html": "<form class=\"tdx-feedback-form\"...>...</form>"
}
```

## API Schema Documentation

This gem integrates with the TeamDynamix (TDX) API system. The complete API specifications are included in the `docs/` directory for reference and development purposes.

### Schema Files

#### `docs/tdxticket.yaml` - TDX Ticket API Specification
**Purpose**: Complete OpenAPI 3.0.1 specification for the TDX ticket management system.

**What it contains**:
- All available API endpoints for ticket operations
- Request/response schemas and data models
- Authentication requirements and error handling
- Field definitions and validation rules

**Key endpoints documented**:
- Ticket creation, updates, and management
- Asset management and search
- Knowledge base operations
- User and group management
- Report generation and access

**How to use it**:
- **Development**: Reference exact field names, data types, and API structure
- **Testing**: Generate mock data based on documented schemas
- **Integration**: Understand required parameters and response formats
- **Troubleshooting**: Verify API behavior against documented specifications

**Example usage in development**:
```ruby
# Reference the schema to understand ticket structure
# From tdxticket.yaml, we know tickets require:
# - appId (integer)
# - typeId (integer)
# - statusId (integer)
# - sourceId (integer)
# - serviceId (integer)
# - responsibleGroupId (integer)

# This helps ensure your configuration matches the API requirements
```

#### `docs/oauthtokenprovider.yaml` - OAuth Token Provider API
**Purpose**: OpenAPI specification for the OAuth2 client credentials flow used for API authentication.

**What it contains**:
- Token endpoint specifications
- Required parameters (scope, grant_type)
- Response schemas (access_token, expires_in, etc.)
- Error handling and status codes

**How to use it**:
- **Authentication**: Understand the OAuth flow requirements
- **Token Management**: Know how to request and handle access tokens
- **Error Handling**: Properly handle authentication failures

**Example usage in development**:
```ruby
# From oauthtokenprovider.yaml, we know the token endpoint requires:
# - scope: 'tdxticket' (as configured in your gem)
# - grant_type: 'client_credentials'
# - Basic auth with client_id/client_secret

# This ensures your OAuth implementation matches the API specification
```

### Why These Schemas Are Included

1. **Single Source of Truth**: Eliminates the need to hunt through external documentation
2. **Development Efficiency**: Developers can quickly understand API structure
3. **Type Safety**: Reference exact field names and data types
4. **Version Control**: Track API changes over time
5. **Testing**: Generate accurate mock data and test scenarios
6. **Onboarding**: New developers understand the external dependencies

### Keeping Schemas Updated

These schemas are provided by the University of Michigan API Directory team. To keep them current:

1. **Monitor for updates** from the official API documentation
2. **Update the YAML files** when new versions are released
3. **Test your integration** after schema updates
4. **Document any breaking changes** in your gem's changelog

### Schema Validation

You can use these OpenAPI schemas with tools like:
- **Swagger UI**: Visualize and test the APIs
- **OpenAPI Generator**: Generate client code in various languages
- **Postman**: Import and test API endpoints
- **API testing frameworks**: Validate responses against schemas

### Related Documentation

- [TeamDynamix API Documentation](https://docs.google.com/document/d/14G-E5Zb2208cHcE5genW5mW0bVEEEtfCTH1N6erP0gA/edit?usp=sharing)
- [UMich API Postman Collections](https://drive.google.com/drive/folders/1OdXufmwJJ_Qy-uSJImlmZImCkN-RqBCE)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

### Testing

The gem includes a comprehensive test suite covering all major functionality.

#### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/configuration_spec.rb
bundle exec rspec spec/client_spec.rb
bundle exec rspec spec/ticket_creator_spec.rb

# Run tests with coverage report
COVERAGE=true bundle exec rspec
```

#### Test Environment Setup

The gem includes a dummy Rails application for testing:

```bash
# Setup test database
cd spec/dummy
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:test:prepare
```

#### Test Coverage

The test suite covers:

- **Configuration Management** - All configuration options and resolution logic
- **TDX Client** - API communication, OAuth token management, error handling
- **Ticket Creation** - TDX ticket creation flow, error scenarios, result handling
- **Controller Actions** - Form submission, validation, authentication
- **Model Validation** - Feedback model constraints and validations
- **Helper Methods** - All view helper functionality
- **Integration Flow** - Complete feedback submission workflow

#### Test Data

Test configuration uses mock TDX credentials:

```ruby
# spec/spec_helper.rb
TdxFeedbackGem.configure do |config|
  config.enable_ticket_creation = true
  config.tdx_base_url = 'https://test-api.example.com'
  config.oauth_token_url = 'https://test-api.example.com/oauth/token'
  config.client_id = 'test_client_id'
  config.client_secret = 'test_client_secret'
  config.app_id = 123
  config.type_id = 456
  config.form_id = 789
  config.service_offering_id = 101
  config.status_id = 112
  config.source_id = 131
  config.service_id = 415
  config.responsible_group_id = 161
end
```

#### Continuous Integration

The gem is configured for CI/CD with:

- RSpec test runner
- Database setup scripts
- Environment-specific configurations
- Coverage reporting
- Linting and style checks

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/tdx_feedback_gem.

## Performance Considerations

### Optimization Tips

#### Asset Optimization

```ruby
# In production.rb
config.assets.compress = true
config.assets.compile = false
config.assets.digest = true

# Precompile assets
bundle exec rails assets:precompile
```

#### Database Optimization

```ruby
# Minimize database queries in modal render
# Use includes for associations if needed
# Consider caching for frequently accessed data
```

#### TDX API Optimization

```ruby
# Cache OAuth tokens appropriately
# Implement retry logic with exponential backoff
# Monitor API rate limits
# Use connection pooling for HTTP requests
```

### CSS Performance

#### Responsive Breakpoints

```css
/* Mobile first approach */
.tdx-feedback-modal {
  /* Base styles for mobile */
}

/* Tablet and up */
@media (min-width: 768px) {
  .tdx-feedback-modal {
    /* Tablet-specific styles */
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .tdx-feedback-modal {
    /* Desktop-specific styles */
  }
}
```

#### Animation Performance

```css
/* Use transform and opacity for smooth animations */
.tdx-feedback-modal {
  transition: transform 0.3s ease-out, opacity 0.3s ease-out;
  transform: translateY(-20px);
  opacity: 0;
}

.tdx-feedback-modal.show {
  transform: translateY(0);
  opacity: 1;
}

/* Hardware acceleration for smooth animations */
.tdx-feedback-modal {
  will-change: transform, opacity;
  transform: translateZ(0);
}
```

### JavaScript Performance

#### Event Handling

```javascript
// Use event delegation for dynamic content
document.addEventListener('click', function(event) {
  if (event.target.matches('.tdx-feedback-trigger')) {
    // Handle feedback trigger clicks
  }
});

// Debounce form submissions
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

const debouncedSubmit = debounce(submitForm, 300);
```

#### Memory Management

```javascript
// Clean up event listeners
function cleanup() {
  // Remove event listeners
  // Clear timeouts
  // Reset form state
}

// Call cleanup when modal closes
document.addEventListener('tdx-feedback:closed', cleanup);
```

## Integration Examples

### Rails 7 with Import Maps

```ruby
# config/importmap.rb
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "tdx_feedback_gem", to: "tdx_feedback_gem.js"

# app/javascript/application.js
import "@hotwired/stimulus-loading"
import "tdx_feedback_gem"
```

### Rails 6 with Webpacker

```javascript
// app/javascript/packs/application.js
import '@hotwired/stimulus'
import 'tdx_feedback_gem'
```

### Rails 5 with Asset Pipeline

```ruby
# app/assets/javascripts/application.js
//= require jquery
//= require jquery_ujs
//= require tdx_feedback_gem
```

### Different Authentication Systems

#### Devise

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def current_user
    current_user # Devise provides this method
  end
end

# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.require_authentication = true
end
```

#### Custom Authentication

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
```

#### No Authentication

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.require_authentication = false
end
```

### Environment-Specific Configurations

#### Development

```ruby
# config/environments/development.rb
config.tdx_feedback_gem = {
  enable_ticket_creation: false,
  log_level: :debug
}
```

#### Staging

```ruby
# config/environments/staging.rb
config.tdx_feedback_gem = {
  enable_ticket_creation: true,
  log_level: :info
}
```

#### Production

```ruby
# config/environments/production.rb
config.tdx_feedback_gem = {
  enable_ticket_creation: true,
  log_level: :warn
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
