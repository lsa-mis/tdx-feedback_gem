Complete REST API documentation for the TDX Feedback Gem, including endpoints, request/response formats, and authentication requirements.

## 📋 Overview

The gem provides a RESTful API for managing feedback submissions. All endpoints support JSON format and include proper error handling, validation, and authentication where required.

## 🔐 Authentication

### CSRF Protection

All API endpoints require CSRF token validation for security.

```erb
<!-- Include CSRF meta tags in your layout -->
<%= csrf_meta_tags %>
<%= csp_meta_tag %>
```

```javascript
// JavaScript will automatically include CSRF token in requests
// Token is read from meta tag: <meta name="csrf-token" content="...">
```

### User Authentication (Optional)

When `require_authentication` is enabled, endpoints require a valid user session.

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.require_authentication = true
end
```

## 📡 Available Endpoints

### 1. Get Feedback Modal

**Endpoint**: `GET /tdx_feedback_gem/feedbacks/new`

**Purpose**: Retrieve the HTML for the feedback modal

**Headers**:
```
Accept: application/json
X-CSRF-Token: [csrf_token]
```

**Response**:
```json
{
  "html": "<div class=\"tdx-feedback-modal\">...</div>",
  "success": true
}
```

**Usage Example**:
```javascript
// Fetch modal HTML
fetch('/tdx_feedback_gem/feedbacks/new', {
  method: 'GET',
  headers: {
    'Accept': 'application/json',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
  }
})
.then(response => response.json())
.then(data => {
  if (data.success) {
    document.body.insertAdjacentHTML('beforeend', data.html);
  }
});
```

### 2. Submit Feedback

**Endpoint**: `POST /tdx_feedback_gem/feedbacks`

**Purpose**: Create a new feedback submission

**Headers**:
```
Content-Type: application/json
Accept: application/json
X-CSRF-Token: [csrf_token]
```

**Request Body**:
```json
{
  "feedback": {
    "message": "User feedback message",
    "context": "Additional context information"
  }
}
```

**Response (Success)**:
```json
{
  "success": true,
  "message": "Feedback submitted successfully",
  "feedback": {
    "id": 123,
    "message": "User feedback message",
    "context": "Additional context information",
    "user_id": 456,
    "tdx_ticket_id": "TDX-2024-001",
    "created_at": "2024-01-15T10:30:00Z"
  }
}
```

**Response (Validation Error)**:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "message": ["can't be blank"]
  }
}
```

**Usage Example**:
```javascript
// Submit feedback
const formData = {
  feedback: {
    message: document.getElementById('feedback-message').value,
    context: document.getElementById('feedback-context').value
  }
};

fetch('/tdx_feedback_gem/feedbacks', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
  },
  body: JSON.stringify(formData)
})
.then(response => response.json())
.then(data => {
  if (data.success) {
    showSuccessMessage(data.message);
    closeModal();
  } else {
    showValidationErrors(data.errors);
  }
});
```

## 🔍 Response Status Codes

### Success Responses

| Status | Meaning | Description |
|--------|---------|-------------|
| `200 OK` | Request successful | Modal HTML returned or feedback updated |
| `201 Created` | Resource created | New feedback submitted successfully |

### Error Responses

| Status | Meaning | Description |
|--------|---------|-------------|
| `400 Bad Request` | Invalid request | Malformed JSON or missing parameters |
| `401 Unauthorized` | Authentication required | User not authenticated when required |
| `422 Unprocessable Entity` | Validation failed | Feedback data validation errors |
| `500 Internal Server Error` | Server error | Unexpected server-side error |

## 📝 Request/Response Schemas

### Feedback Object Schema

```json
{
  "feedback": {
    "message": "string (required, max 10000 chars)",
    "context": "string (optional, max 10000 chars)"
  }
}
```

### Response Schema

```json
{
  "success": "boolean",
  "message": "string",
  "feedback": {
    "id": "integer",
    "message": "string",
    "context": "string|null",
    "user_id": "integer|null",
    "tdx_ticket_id": "string|null",
    "created_at": "datetime",
    "updated_at": "datetime"
  },
  "errors": {
    "field_name": ["array of error messages"]
  }
}
```

## 🚨 Error Handling

### Validation Errors

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "message": ["can't be blank", "is too long (maximum is 10000 characters)"],
    "context": ["is too long (maximum is 10000 characters)"]
  }
}
```

### Authentication Errors

```json
{
  "success": false,
  "message": "Authentication required",
  "errors": {
    "base": ["User must be logged in to submit feedback"]
  }
}
```

### Server Errors

```json
{
  "success": false,
  "message": "Internal server error",
  "errors": {
    "base": ["An unexpected error occurred. Please try again later."]
  }
}
```

## 🔧 Advanced Usage

### Custom Headers

```javascript
// Add custom headers for tracking
fetch('/tdx_feedback_gem/feedbacks', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
    'X-Requested-With': 'XMLHttpRequest',
    'X-User-Agent': navigator.userAgent,
    'X-Page-URL': window.location.href
  },
  body: JSON.stringify(formData)
});
```

### Error Handling with Retry

```javascript
async function submitFeedbackWithRetry(formData, maxRetries = 3) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch('/tdx_feedback_gem/feedbacks', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify(formData)
      });

      if (response.ok) {
        return await response.json();
      }

      // Handle specific error codes
      if (response.status === 422) {
        const errorData = await response.json();
        throw new Error(`Validation failed: ${JSON.stringify(errorData.errors)}`);
      }

      if (response.status === 401) {
        throw new Error('Authentication required');
      }

      throw new Error(`HTTP ${response.status}: ${response.statusText}`);

    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }

      // Wait before retry (exponential backoff)
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
    }
  }
}
```

### Form Validation

```javascript
// Client-side validation before submission
function validateFeedbackForm(formData) {
  const errors = {};

  if (!formData.feedback.message || formData.feedback.message.trim().length === 0) {
    errors.message = ['Message is required'];
  } else if (formData.feedback.message.length > 10000) {
    errors.message = ['Message is too long (maximum is 10000 characters)'];
  }

  if (formData.feedback.context && formData.feedback.context.length > 10000) {
    errors.context = ['Context is too long (maximum is 10000 characters)'];
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors: errors
  };
}

// Usage
const formData = {
  feedback: {
    message: document.getElementById('feedback-message').value,
    context: document.getElementById('feedback-context').value
  }
};

const validation = validateFeedbackForm(formData);
if (!validation.isValid) {
  showValidationErrors(validation.errors);
  return;
}

// Submit if valid
submitFeedback(formData);
```

## 📊 API Testing

### Using cURL

```bash
# Get feedback modal
curl -X GET "http://localhost:3000/tdx_feedback_gem/feedbacks/new" \
  -H "Accept: application/json" \
  -H "X-CSRF-Token: your_csrf_token_here"

# Submit feedback
curl -X POST "http://localhost:3000/tdx_feedback_gem/feedbacks" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "X-CSRF-Token: your_csrf_token_here" \
  -d '{
    "feedback": {
      "message": "Test feedback message",
      "context": "Test context information"
    }
  }'
```

### Using Postman

1. **Create a new collection** for TDX Feedback Gem
2. **Set up environment variables**:
   - `base_url`: `http://localhost:3000`
   - `csrf_token`: Your CSRF token
3. **Create requests** for each endpoint
4. **Test with different data** and error scenarios

### Using RSpec

```ruby
# spec/requests/feedback_api_spec.rb
RSpec.describe 'Feedback API', type: :request do
  describe 'GET /tdx_feedback_gem/feedbacks/new' do
    it 'returns modal HTML' do
      get '/tdx_feedback_gem/feedbacks/new', headers: { 'Accept' => 'application/json' }

      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['html']).to include('tdx-feedback-modal')
    end
  end

  describe 'POST /tdx_feedback_gem/feedbacks' do
    context 'with valid data' do
      it 'creates feedback successfully' do
        post '/tdx_feedback_gem/feedbacks', params: {
          feedback: { message: 'Test feedback' }
        }, headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['feedback']['message']).to eq('Test feedback')
      end
    end

    context 'with invalid data' do
      it 'returns validation errors' do
        post '/tdx_feedback_gem/feedbacks', params: {
          feedback: { message: '' }
        }, headers: { 'Accept' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']['message']).to include("can't be blank")
      end
    end
  end
end
```

## 🔒 Security Considerations

### CSRF Protection

- All endpoints require valid CSRF tokens
- Tokens are automatically included in JavaScript requests
- Manual token handling required for external API clients

### Input Validation

- Server-side validation for all input fields
- Length limits to prevent abuse
- Content sanitization for XSS protection

### Rate Limiting

```ruby
# config/initializers/tdx_feedback_gem.rb
TdxFeedbackGem.configure do |config|
  config.rate_limit = 10  # Max 10 requests per minute per IP
  config.rate_limit_window = 1.minute
end
```

## 📈 Performance Optimization

### Response Caching

```ruby
# Cache modal HTML responses
class TdxFeedbackGem::FeedbacksController < ApplicationController
  def new
    @modal_html = Rails.cache.fetch("feedback_modal_#{current_user&.id}", expires_in: 1.hour) do
      render_to_string(partial: 'modal', layout: false)
    end

    render json: { success: true, html: @modal_html }
  end
end
```

### Database Optimization

```ruby
# Use database transactions for feedback creation
def create
  ActiveRecord::Base.transaction do
    @feedback = TdxFeedbackGem::Feedback.new(feedback_params)
    @feedback.user = current_user if current_user

    if @feedback.save
      # Create TDX ticket if enabled
      if TdxFeedbackGem.configuration.enable_ticket_creation?
        create_tdx_ticket(@feedback)
      end

      render json: { success: true, feedback: @feedback }, status: :created
    else
      render json: { success: false, errors: @feedback.errors }, status: :unprocessable_entity
    end
  end
rescue => e
  render json: { success: false, message: 'Internal server error' }, status: :internal_server_error
end
```

## 🔄 Next Steps

Now that you understand the API endpoints:

1. **[Performance Optimization](Performance-Optimization)** - Optimize API performance
2. **[Production Deployment](Production-Deployment)** - Deploy with API security
3. **[Testing Guide](Testing)** - Test your API integration
4. **[Database Schema](Database-Schema)** - Understand the data structure

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more details about the database structure, see the [Database Schema](Database-Schema) guide.*
