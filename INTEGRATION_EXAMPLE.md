# Integration Example

This file shows how to integrate the TDX Feedback Gem into your main Rails application.

## Step 1: Add to Gemfile

```ruby
# Gemfile
gem 'tdx_feedback_gem'
```

## Step 2: Install and Configure

```bash
bundle install
rails generate tdx_feedback_gem:install
```

## Step 3: Ensure Stimulus is Available

The gem requires Stimulus to work. Make sure your application has Stimulus set up:

```bash
# If using Rails 7+
rails new myapp --javascript=stimulus

# Or manually add to your Gemfile
gem 'stimulus-rails'
```

## Step 4: Add to Your Layout

### Option A: Footer Link (Recommended)

```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title>Your App</title>
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <header>
      <nav>
        <!-- Your navigation -->
      </nav>
    </header>

    <main>
      <%= yield %>
    </main>

    <footer>
      <div class="footer-content">
        <p>&copy; 2024 Your App</p>
        <%= feedback_footer_link %>
      </div>
    </footer>
  </body>
</html>
```

### Option B: Header Button

```erb
<!-- app/views/layouts/application.html.erb -->
<header>
  <nav>
    <div class="nav-left">
      <!-- Your navigation -->
    </div>
    <div class="nav-right">
      <%= feedback_header_button %>
    </nav>
</header>
```

### Option C: Custom Placement

```erb
<!-- Any view where you want feedback -->
<div class="help-section">
  <h3>Need Help?</h3>
  <p>We'd love to hear your feedback!</p>
  <%= feedback_button('Send Feedback', class: 'btn-help') %>
</div>
```

### Option D: Stimulus-Powered Integration

```erb
<!-- For advanced customization -->
<%= feedback_trigger(
  type: :button,
  text: 'Feedback',
  class: 'btn-primary',
  data: {
    'custom-attribute': 'value',
    'analytics-event': 'feedback_clicked'
  }
) %>
```

## Step 5: Customize Styling (Optional)

```css
/* app/assets/stylesheets/application.css */

/* Customize the feedback modal to match your app */
.tdx-feedback-modal-content {
  border-radius: 12px;
  box-shadow: 0 25px 50px rgba(0, 0, 0, 0.25);
}

.tdx-feedback-submit {
  background-color: #007bff; /* Your brand color */
}

.tdx-feedback-link {
  color: #6c757d;
  text-decoration: none;
}

.tdx-feedback-link:hover {
  color: #007bff;
  text-decoration: underline;
}
```

## Step 6: Test the Integration

1. Start your Rails server
2. Navigate to any page
3. Click the feedback link/button
4. The modal should open with the feedback form
5. Fill out and submit the form
6. The modal should close and you should stay on the same page

## Advanced Usage

### Custom Feedback Text

```erb
<%= feedback_link('Report a Bug', class: 'bug-report-link') %>
<%= feedback_button('Suggest Feature', class: 'feature-request-btn') %>
```

### Multiple Feedback Triggers

```erb
<!-- In your header -->
<%= feedback_icon(class: 'header-feedback-icon') %>

<!-- In your sidebar -->
<%= feedback_link('Feedback', class: 'sidebar-feedback') %>

<!-- In your footer -->
<%= feedback_footer_link %>
```

### Custom Modal Styling

```css
/* Make the modal match your app's theme */
.tdx-feedback-modal-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.tdx-feedback-modal-header h3 {
  color: white;
}

.tdx-feedback-input,
.tdx-feedback-textarea {
  border-color: rgba(255, 255, 255, 0.3);
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.tdx-feedback-input::placeholder,
.tdx-feedback-textarea::placeholder {
  color: rgba(255, 255, 255, 0.7);
}
```

### Stimulus Controller Customization

You can extend the default Stimulus controller for custom behavior:

```javascript
// app/javascript/controllers/tdx_feedback_controller.js
import TdxFeedbackController from 'tdx_feedback_gem/tdx_feedback_controller'

export default class extends TdxFeedbackController {
  // Override the open method
  open() {
    // Track analytics before opening
    if (window.gtag) {
      gtag('event', 'feedback_modal_opened')
    }

    // Call the parent method
    super.open()
  }

  // Override the close method
  close() {
    // Track analytics before closing
    if (window.gtag) {
      gtag('event', 'feedback_modal_closed')
    }

    // Call the parent method
    super.close()
  }

  // Add custom form validation
  handleSubmit(event) {
    // Your custom validation logic here
    if (this.validateForm()) {
      super.handleSubmit(event)
    }
  }

  validateForm() {
    // Custom validation logic
    return true
  }
}
```

### Listening to Modal Events

```javascript
// Listen for modal lifecycle events
document.addEventListener('tdx-feedback:opened', function(event) {
  console.log('Feedback modal opened', event.detail)
  // Your custom code here
})

document.addEventListener('tdx-feedback:closed', function(event) {
  console.log('Feedback modal closed', event.detail)
  // Your custom code here
})
```

## Troubleshooting

### Modal Not Opening

1. Check that Stimulus is properly loaded:
   ```erb
   <%= javascript_include_tag 'application' %>
   ```

2. Check the browser console for JavaScript errors

3. Verify the routes are mounted correctly

4. Ensure the Stimulus controller is registered:
   ```javascript
   // app/javascript/controllers/index.js
   import { application } from "./application"
   import TdxFeedbackController from "./tdx_feedback_controller"
   application.register("tdx-feedback", TdxFeedbackController)
   ```

### Styling Issues

1. Make sure the CSS is included:
   ```erb
   <%= stylesheet_link_tag 'tdx_feedback_gem' %>
   ```

2. Check for CSS conflicts with your main application

3. Use browser dev tools to inspect the modal elements

### Form Submission Issues

1. Check that CSRF tokens are properly configured
2. Verify the TDX API configuration
3. Check the Rails logs for any errors
4. Ensure the Stimulus controller is handling form submission correctly

## That's It!

Your Rails application now has a professional, modal-based feedback system powered by Stimulus that users can access from anywhere without leaving their current page. The system is completely self-contained, modern, and won't interfere with your existing functionality.
