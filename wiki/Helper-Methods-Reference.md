Complete reference for all available view helper methods provided by the TDX Feedback Gem.

## 📋 Overview

The gem provides several helper methods for easy integration of feedback functionality into your Rails views. These helpers generate the appropriate HTML and JavaScript for the feedback system.

## 🔗 Basic Helper Methods

### `feedback_footer_link`

Generates a simple feedback link suitable for footers.

**Usage**:
```erb
<%= feedback_footer_link %>
```

**Generated HTML**:
```html
<a href="#" class="tdx-feedback-link tdx-feedback-footer-link" data-action="click->tdx-feedback#openModal">
  Send Feedback
</a>
```

**Options**:
```erb
<%= feedback_footer_link(text: 'Report Issue', class: 'custom-link') %>
```

**Parameters**:
- `text` (string): Link text (default: "Send Feedback")
- `class` (string): Additional CSS classes
- `id` (string): HTML ID attribute

### `feedback_header_button`

Generates a feedback button suitable for headers or prominent placement.

**Usage**:
```erb
<%= feedback_header_button %>
```

**Generated HTML**:
```html
<button type="button" class="tdx-feedback-button tdx-feedback-header-button" data-action="click->tdx-feedback#openModal">
  Send Feedback
</button>
```

**Options**:
```erb
<%= feedback_header_button(text: 'Feedback', class: 'btn-primary', id: 'header-feedback') %>
```

**Parameters**:
- `text` (string): Button text (default: "Send Feedback")
- `class` (string): Additional CSS classes
- `id` (string): HTML ID attribute

### `feedback_link`

Generates a custom feedback link with full control over appearance.

**Usage**:
```erb
<%= feedback_link('Report Bug', class: 'bug-report-link', id: 'bug-feedback') %>
```

**Generated HTML**:
```html
<a href="#" class="tdx-feedback-link bug-report-link" id="bug-feedback" data-action="click->tdx-feedback#openModal">
  Report Bug
</a>
```

**Parameters**:
- `text` (string): Link text (required)
- `class` (string): CSS classes
- `id` (string): HTML ID attribute
- `data` (hash): Additional data attributes

### `feedback_icon`

Generates a feedback icon link.

**Usage**:
```erb
<%= feedback_icon %>
```

**Generated HTML**:
```html
<a href="#" class="tdx-feedback-icon" data-action="click->tdx-feedback#openModal">
  <svg class="tdx-feedback-icon-svg" viewBox="0 0 24 24">
    <!-- SVG content -->
  </svg>
</a>
```

**Options**:
```erb
<%= feedback_icon(class: 'header-icon', size: 'large') %>
```

**Parameters**:
- `class` (string): Additional CSS classes
- `size` (string): Icon size (small, medium, large)
- `id` (string): HTML ID attribute

## 🎯 Advanced Helper Methods

### `feedback_system`

Generates a complete feedback system with customizable trigger and appearance.

**Usage**:
```erb
<%= feedback_system %>
```

**Generated HTML**:
```html
<div class="tdx-feedback-system">
  <a href="#" class="tdx-feedback-link" data-action="click->tdx-feedback#openModal">
    Send Feedback
  </a>
</div>
```

**Options**:
```erb
<%= feedback_system(
  trigger: :button,
  text: 'Report Issue',
  class: 'btn-danger',
  id: 'issue-feedback',
  data: { feedback_type: 'bug' }
) %>
```

**Parameters**:
- `trigger` (symbol): Trigger type (`:link`, `:button`, `:icon`)
- `text` (string): Trigger text
- `class` (string): CSS classes
- `id` (string): HTML ID attribute
- `data` (hash): Data attributes

**Trigger Types**:
- `:link` - Generates an `<a>` tag
- `:button` - Generates a `<button>` tag
- `:icon` - Generates an icon link

### `feedback_trigger`

Generates a custom feedback trigger with advanced options.

**Usage**:
```erb
<%= feedback_trigger(type: :button, text: 'Feedback', class: 'btn-primary') %>
```

**Generated HTML**:
```html
<button type="button" class="tdx-feedback-button btn-primary" data-action="click->tdx-feedback#openModal">
  Feedback
</button>
```

**Parameters**:
- `type` (symbol): Element type (`:link`, `:button`, `:icon`)
- `text` (string): Trigger text
- `class` (string): CSS classes
- `id` (string): HTML ID attribute
- `data` (hash): Data attributes
- `attributes` (hash): Additional HTML attributes

## 🎨 Styling and Customization

### CSS Classes

Each helper method generates specific CSS classes for styling:

```css
/* Base feedback classes */
.tdx-feedback-link              /* All feedback links */
.tdx-feedback-button            /* All feedback buttons */
.tdx-feedback-icon              /* All feedback icons */

/* Specific helper classes */
.tdx-feedback-footer-link       /* Footer link specific */
.tdx-feedback-header-button     /* Header button specific */
.tdx-feedback-system            /* System wrapper */

/* State classes */
.tdx-feedback-disabled          /* Disabled state */
.tdx-feedback-loading           /* Loading state */
```

### Custom Styling Examples

#### Custom Button Styles

```erb
<%= feedback_header_button(class: 'btn btn-primary btn-lg') %>
```

```css
/* Custom button styling */
.tdx-feedback-button.btn-primary {
  background: #007bff;
  border-color: #007bff;
  color: white;
  padding: 12px 24px;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s;
}

.tdx-feedback-button.btn-primary:hover {
  background: #0056b3;
  border-color: #0056b3;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 123, 255, 0.3);
}
```

#### Custom Link Styles

```erb
<%= feedback_footer_link(class: 'footer-feedback-link') %>
```

```css
/* Custom footer link styling */
.tdx-feedback-footer-link {
  color: #6c757d;
  text-decoration: none;
  font-size: 0.875rem;
  padding: 8px 0;
  transition: color 0.2s;
}

.tdx-feedback-footer-link:hover {
  color: #495057;
  text-decoration: underline;
}
```

#### Custom Icon Styles

```erb
<%= feedback_icon(class: 'header-feedback-icon', size: 'large') %>
```

```css
/* Custom icon styling */
.tdx-feedback-icon.header-feedback-icon {
  color: #6c757d;
  transition: all 0.2s;
}

.tdx-feedback-icon.header-feedback-icon:hover {
  color: #007bff;
  transform: scale(1.1);
}

.tdx-feedback-icon.header-feedback-icon.size-large .tdx-feedback-icon-svg {
  width: 32px;
  height: 32px;
}
```

## 🔧 Data Attributes

### Default Data Attributes

All helper methods automatically include these data attributes:

```html
data-action="click->tdx-feedback#openModal"
data-controller="tdx-feedback"
```

### Custom Data Attributes

You can add custom data attributes for advanced functionality:

```erb
<%= feedback_system(
  trigger: :button,
  text: 'Report Bug',
  data: {
    feedback_type: 'bug',
    page_url: request.url,
    user_id: current_user&.id
  }
) %>
```

**Generated HTML**:
```html
<div class="tdx-feedback-system">
  <button type="button" class="tdx-feedback-button"
          data-action="click->tdx-feedback#openModal"
          data-controller="tdx-feedback"
          data-feedback-type="bug"
          data-page-url="https://example.com/page"
          data-user-id="123">
    Report Bug
  </button>
</div>
```

### Using Data Attributes in JavaScript

```javascript
// Access custom data attributes
document.addEventListener('tdx-feedback:opened', function(event) {
  const trigger = event.target;
  const feedbackType = trigger.dataset.feedbackType;
  const pageUrl = trigger.dataset.pageUrl;
  const userId = trigger.dataset.userId;

  console.log('Feedback opened:', { feedbackType, pageUrl, userId });
});
```

## 🎭 Conditional Rendering

### Authentication-Based Rendering

```erb
<% if current_user %>
  <%= feedback_header_button %>
<% else %>
  <%= link_to 'Sign In to Give Feedback', login_path %>
<% end %>
```

### Role-Based Rendering

```erb
<% if current_user&.admin? %>
  <%= feedback_system(
    trigger: :button,
    text: 'Admin Feedback',
    class: 'btn-warning',
    data: { user_role: 'admin' }
  ) %>
<% elsif current_user&.moderator? %>
  <%= feedback_system(
    trigger: :button,
    text: 'Moderator Feedback',
    class: 'btn-info',
    data: { user_role: 'moderator' }
  ) %>
<% else %>
  <%= feedback_header_button %>
<% end %>
```

### Environment-Based Rendering

```erb
<% if Rails.env.development? %>
  <%= feedback_system(
    trigger: :button,
    text: 'Dev Feedback',
    class: 'btn-secondary',
    data: { environment: 'development' }
  ) %>
<% else %>
  <%= feedback_header_button %>
<% end %>
```

## 📱 Responsive Design

### Mobile-First Approach

```erb
<!-- Responsive feedback button -->
<%= feedback_system(
  trigger: :button,
  text: 'Feedback',
  class: 'btn-primary d-none d-md-inline-block'
) %>

<!-- Mobile-only feedback icon -->
<%= feedback_icon(class: 'd-md-none') %>
```

### Responsive CSS

```css
/* Mobile styles */
@media (max-width: 768px) {
  .tdx-feedback-button {
    padding: 8px 16px;
    font-size: 0.875rem;
  }

  .tdx-feedback-icon {
    width: 32px;
    height: 32px;
  }
}

/* Desktop styles */
@media (min-width: 769px) {
  .tdx-feedback-button {
    padding: 12px 24px;
    font-size: 1rem;
  }

  .tdx-feedback-icon {
    width: 40px;
    height: 40px;
  }
}
```

## 🔄 Integration Examples

### Layout Integration

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
    <header class="navbar navbar-expand-lg navbar-light bg-light">
      <div class="container">
        <a class="navbar-brand" href="/">Your App</a>

        <div class="navbar-nav ms-auto">
          <%= feedback_header_button(class: 'btn btn-outline-primary') %>
        </div>
      </div>
    </header>

    <main class="container my-4">
      <%= yield %>
    </main>

    <footer class="bg-light py-4 mt-5">
      <div class="container">
        <div class="row">
          <div class="col-md-6">
            <p>&copy; 2024 Your App. All rights reserved.</p>
          </div>
          <div class="col-md-6 text-end">
            <%= feedback_footer_link(class: 'text-muted') %>
          </div>
        </div>
      </div>
    </footer>
  </body>
</html>
```

### Page-Specific Integration

```erb
<!-- app/views/pages/show.html.erb -->
<div class="page-header">
  <h1><%= @page.title %></h1>

  <div class="page-actions">
    <%= feedback_system(
      trigger: :button,
      text: 'Feedback on this page',
      class: 'btn btn-outline-primary',
      data: {
        page_id: @page.id,
        page_title: @page.title,
        feedback_context: "User was viewing page: #{@page.title}"
      }
    ) %>
  </div>
</div>

<div class="page-content">
  <%= @page.content %>
</div>
```

### Component Integration

```erb
<!-- app/views/components/_feedback_widget.html.erb -->
<div class="feedback-widget">
  <h3>Help us improve</h3>
  <p>Found an issue or have a suggestion? Let us know!</p>

  <div class="feedback-actions">
    <%= feedback_system(
      trigger: :button,
      text: 'Send Feedback',
      class: 'btn btn-primary'
    ) %>

    <%= feedback_system(
      trigger: :link,
      text: 'Report Bug',
      class: 'text-muted ms-3',
      data: { feedback_type: 'bug' }
    ) %>
  </div>
</div>
```

## 🚀 Performance Optimization

### Lazy Loading

```erb
<!-- Load feedback helpers only when needed -->
<% if show_feedback? %>
  <%= feedback_header_button %>
<% end %>
```

### Conditional Asset Loading

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Only load feedback assets when needed
    config.assets.precompile += %w( tdx_feedback_gem.js tdx_feedback_gem.css )
  end
end
```

### Caching

```erb
<!-- Cache feedback components -->
<% cache ['feedback_widget', current_user&.id] do %>
  <%= feedback_system(
    trigger: :button,
    text: 'Send Feedback',
    class: 'btn btn-primary'
  ) %>
<% end %>
```

## 🔄 Next Steps

Now that you understand the helper methods:

1. **[Styling and Theming](Styling-and-Theming)** - Customize the appearance
2. **[Advanced Customization](Advanced-Customization)** - Extend functionality
3. **[Testing Guide](Testing)** - Test your integration
4. **[Performance Optimization](Performance-Optimization)** - Optimize performance

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For advanced customization options, see the [Advanced Customization](Advanced-Customization) guide.*
