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

```ruby
TdxFeedbackGem.configure do |config|
  # === Authentication ===
  # Require authenticated user (expects current_user method)
  config.require_authentication = false

  # === TDX API Integration ===
  # Enable automatic ticket creation via TDX API
  config.enable_ticket_creation = false

  # TDX API base URL and OAuth endpoints
  config.tdx_base_url = 'https://gw-test.api.it.umich.edu/um/it'
  config.oauth_token_url = 'https://gw-test.api.it.umich.edu/um/it/oauth2/token'

  # OAuth2 client credentials (use ENV variables for security)
  config.client_id = ENV['TDX_CLIENT_ID']
  config.client_secret = ENV['TDX_CLIENT_SECRET']
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

#### Environment Variables (Recommended)

For better security, use environment variables:

```bash
# .env or your environment configuration
TDX_CLIENT_ID=your_client_id_here
TDX_CLIENT_SECRET=your_client_secret_here
```

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/tdx_feedback_gem.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
