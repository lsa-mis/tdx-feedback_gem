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
gem 'tdx_feedback_gem'
```

And then execute:

```bash
$ bundle install
```

## Configuration

Create an initializer file:

```bash
$ rails generate tdx_feedback_gem:install
```

This will create `config/initializers/tdx_feedback_gem.rb` with configuration options:

```ruby
TdxFeedbackGem.configure do |config|
  config.enable_ticket_creation = true
  config.require_authentication = false
  # Add your TDX API configuration here
end
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

### Customization

#### Styling

The modal comes with default styles that you can override in your application's CSS:

```css
/* Customize modal appearance */
.tdx-feedback-modal-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.tdx-feedback-submit {
  background-color: #28a745;
}
```

#### JavaScript Events

You can listen to modal events for custom behavior:

```javascript
// Listen for modal open/close events
document.addEventListener('tdx-feedback:opened', function() {
  console.log('Feedback modal opened');
});

document.addEventListener('tdx-feedback:closed', function() {
  console.log('Feedback modal closed');
});
```

#### Stimulus Controller Customization

The gem uses a Stimulus controller (`tdx-feedback`) that you can extend:

```javascript
// app/javascript/controllers/tdx_feedback_controller.js
import TdxFeedbackController from 'tdx_feedback_gem/tdx_feedback_controller'

export default class extends TdxFeedbackController {
  // Override or extend methods as needed
  open() {
    // Custom open behavior
    super.open()
    // Your custom code here
  }
}
```

## API Endpoints

The gem provides these endpoints (all JSON-based):

- `GET /tdx_feedback_gem/feedbacks/new` - Returns modal HTML
- `POST /tdx_feedback_gem/feedbacks` - Submits feedback

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/tdx_feedback_gem.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
