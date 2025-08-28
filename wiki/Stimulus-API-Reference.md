Complete reference for the Stimulus controller used by the TDX Feedback Gem, including all methods, events, targets, and customization options.

## 📋 Overview

The TDX Feedback Gem uses Stimulus to manage the feedback modal and form interactions. This controller handles opening/closing the modal, form submission, validation, and user interactions.

## 🎮 Controller Definition

### Basic Controller Structure

```javascript
// app/javascript/controllers/tdx_feedback_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "message", "context", "submitButton", "closeButton"]
  static values = {
    autoOpen: Boolean,
    feedbackType: String,
    pageUrl: String,
    userId: String
  }

  connect() {
    this.setupEventListeners()
    this.initializeModal()
  }

  disconnect() {
    this.cleanupEventListeners()
  }
}
```

## 🎯 Targets

### Available Targets

| Target | Description | HTML Element |
|--------|-------------|--------------|
| `modal` | The feedback modal container | `.tdx-feedback-modal` |
| `form` | The feedback form | `form.tdx-feedback-form` |
| `message` | Message input field | `textarea[name="feedback[message]"]` |
| `context` | Context input field | `textarea[name="feedback[context]"]` |
| `submitButton` | Form submit button | `button[type="submit"]` |
| `closeButton` | Modal close button | `button[data-action="click->tdx-feedback#closeModal"]` |
| `overlay` | Modal backdrop | `.tdx-feedback-modal-overlay` |
| `content` | Modal content area | `.tdx-feedback-modal-content` |
| `loading` | Loading indicator | `.tdx-feedback-loading` |
| `error` | Error message display | `.tdx-feedback-error` |
| `success` | Success message display | `.tdx-feedback-success` |

### Target Usage Examples

```html
<!-- Modal container -->
<div class="tdx-feedback-modal" data-tdx-feedback-target="modal">

  <!-- Modal content -->
  <div class="tdx-feedback-modal-content" data-tdx-feedback-target="content">

    <!-- Form -->
    <form class="tdx-feedback-form" data-tdx-feedback-target="form">

      <!-- Message input -->
      <textarea
        name="feedback[message]"
        data-tdx-feedback-target="message"
        placeholder="Your feedback message..."
      ></textarea>

      <!-- Context input -->
      <textarea
        name="feedback[context]"
        data-tdx-feedback-target="context"
        placeholder="Additional context (optional)..."
      ></textarea>

      <!-- Submit button -->
      <button
        type="submit"
        data-tdx-feedback-target="submitButton"
      >
        Submit Feedback
      </button>
    </form>

    <!-- Close button -->
    <button
      data-action="click->tdx-feedback#closeModal"
      data-tdx-feedback-target="closeButton"
    >
      ×
    </button>
  </div>

  <!-- Overlay -->
  <div class="tdx-feedback-modal-overlay" data-tdx-feedback-target="overlay"></div>
</div>
```

## 🔧 Values

### Available Values

| Value | Type | Default | Description |
|-------|------|---------|-------------|
| `autoOpen` | Boolean | `false` | Automatically open modal when controller connects |
| `feedbackType` | String | `'general'` | Type of feedback being submitted |
| `pageUrl` | String | `window.location.href` | URL of the current page |
| `userId` | String | `null` | ID of the current user |
| `debug` | Boolean | `false` | Enable debug logging |
| `animation` | Boolean | `true` | Enable modal animations |
| `closeOnOverlay` | Boolean | `true` | Close modal when clicking overlay |
| `closeOnEscape` | Boolean | `true` | Close modal when pressing Escape |

### Value Usage Examples

```html
<!-- Basic usage -->
<div data-controller="tdx-feedback">
  <button data-action="click->tdx-feedback#openModal">Feedback</button>
</div>

<!-- With custom values -->
<div
  data-controller="tdx-feedback"
  data-tdx-feedback-feedback-type-value="bug"
  data-tdx-feedback-page-url-value="/dashboard"
  data-tdx-feedback-user-id-value="123"
  data-tdx-feedback-debug-value="true"
>
  <button data-action="click->tdx-feedback#openModal">Report Bug</button>
</div>

<!-- Auto-opening modal -->
<div
  data-controller="tdx-feedback"
  data-tdx-feedback-auto-open-value="true"
  data-tdx-feedback-feedback-type-value="welcome"
>
  <!-- Modal will open automatically -->
</div>
```

## 🎭 Actions

### Available Actions

| Action | Description | Usage |
|--------|-------------|-------|
| `openModal` | Open the feedback modal | `data-action="click->tdx-feedback#openModal"` |
| `closeModal` | Close the feedback modal | `data-action="click->tdx-feedback#closeModal"` |
| `submitForm` | Submit the feedback form | `data-action="submit->tdx-feedback#submitForm"` |
| `validateForm` | Validate form inputs | `data-action="input->tdx-feedback#validateForm"` |
| `clearForm` | Clear all form inputs | `data-action="click->tdx-feedback#clearForm"` |
| `toggleModal` | Toggle modal open/close state | `data-action="click->tdx-feedback#toggleModal"` |

### Action Usage Examples

```html
<!-- Button triggers -->
<button data-action="click->tdx-feedback#openModal">Open Feedback</button>
<button data-action="click->tdx-feedback#closeModal">Close</button>
<button data-action="click->tdx-feedback#toggleModal">Toggle</button>

<!-- Form actions -->
<form data-action="submit->tdx-feedback#submitForm">
  <!-- Form content -->
</form>

<!-- Input validation -->
<textarea
  data-action="input->tdx-feedback#validateForm"
  name="feedback[message]"
></textarea>

<!-- Utility actions -->
<button data-action="click->tdx-feedback#clearForm">Clear Form</button>
```

## 📝 Methods

### Core Methods

#### `connect()`
Called when the controller connects to the DOM.

```javascript
connect() {
  this.setupEventListeners()
  this.initializeModal()

  // Auto-open if configured
  if (this.autoOpenValue) {
    this.openModal()
  }

  // Debug logging
  if (this.debugValue) {
    console.log('TDX Feedback Controller connected', {
      feedbackType: this.feedbackTypeValue,
      pageUrl: this.pageUrlValue,
      userId: this.userIdValue
    })
  }
}
```

#### `disconnect()`
Called when the controller disconnects from the DOM.

```javascript
disconnect() {
  this.cleanupEventListeners()
  this.closeModal()

  if (this.debugValue) {
    console.log('TDX Feedback Controller disconnected')
  }
}
```

### Modal Management Methods

#### `openModal()`
Open the feedback modal with animation.

```javascript
openModal() {
  if (this.modalTarget) {
    // Show modal
    this.modalTarget.classList.add('show')

    // Focus first input
    this.messageTarget?.focus()

    // Add body scroll lock
    document.body.classList.add('modal-open')

    // Dispatch custom event
    this.dispatch('modalOpened', {
      detail: {
        feedbackType: this.feedbackTypeValue,
        pageUrl: this.pageUrlValue
      }
    })

    if (this.debugValue) {
      console.log('Modal opened')
    }
  }
}
```

#### `closeModal()`
Close the feedback modal with animation.

```javascript
closeModal() {
  if (this.modalTarget) {
    // Hide modal
    this.modalTarget.classList.remove('show')

    // Remove body scroll lock
    document.body.classList.remove('modal-open')

    // Clear form
    this.clearForm()

    // Dispatch custom event
    this.dispatch('modalClosed')

    if (this.debugValue) {
      console.log('Modal closed')
    }
  }
}
```

#### `toggleModal()`
Toggle the modal open/close state.

```javascript
toggleModal() {
  if (this.modalTarget.classList.contains('show')) {
    this.closeModal()
  } else {
    this.openModal()
  }
}
```

### Form Management Methods

#### `submitForm(event)`
Handle form submission.

```javascript
async submitForm(event) {
  event.preventDefault()

  if (this.debugValue) {
    console.log('Form submission started')
  }

  // Validate form
  if (!this.validateForm()) {
    return
  }

  // Show loading state
  this.showLoading()

  try {
    // Prepare form data
    const formData = this.prepareFormData()

    // Submit to server
    const response = await this.submitToServer(formData)

    if (response.success) {
      this.showSuccess(response.message)
      this.closeModal()

      // Dispatch success event
      this.dispatch('feedbackSubmitted', {
        detail: {
          feedback: response.feedback,
          ticketId: response.ticket_id
        }
      })
    } else {
      this.showErrors(response.errors)
    }
  } catch (error) {
    this.showError('An error occurred while submitting feedback. Please try again.')

    if (this.debugValue) {
      console.error('Form submission error:', error)
    }
  } finally {
    this.hideLoading()
  }
}
```

#### `validateForm()`
Validate form inputs and show errors.

```javascript
validateForm() {
  let isValid = true
  const errors = {}

  // Validate message
  const message = this.messageTarget.value.trim()
  if (!message) {
    errors.message = 'Message is required'
    isValid = false
  } else if (message.length > 10000) {
    errors.message = 'Message is too long (maximum 10000 characters)'
    isValid = false
  }

  // Validate context (optional)
  if (this.contextTarget) {
    const context = this.contextTarget.value.trim()
    if (context && context.length > 10000) {
      errors.context = 'Context is too long (maximum 10000 characters)'
      isValid = false
    }
  }

  // Show/hide errors
  this.showValidationErrors(errors)

  return isValid
}
```

#### `clearForm()`
Clear all form inputs and errors.

```javascript
clearForm() {
  if (this.messageTarget) {
    this.messageTarget.value = ''
  }

  if (this.contextTarget) {
    this.contextTarget.value = ''
  }

  this.clearErrors()

  if (this.debugValue) {
    console.log('Form cleared')
  }
}
```

### Utility Methods

#### `prepareFormData()`
Prepare form data for submission.

```javascript
prepareFormData() {
  const formData = new FormData()

  // Add feedback data
  formData.append('feedback[message]', this.messageTarget.value.trim())

  if (this.contextTarget && this.contextTarget.value.trim()) {
    formData.append('feedback[context]', this.contextTarget.value.trim())
  }

  // Add metadata
  formData.append('feedback[feedback_type]', this.feedbackTypeValue)
  formData.append('feedback[page_url]', this.pageUrlValue)

  if (this.userIdValue) {
    formData.append('feedback[user_id]', this.userIdValue)
  }

  return formData
}
```

#### `submitToServer(formData)`
Submit form data to the server.

```javascript
async submitToServer(formData) {
  const response = await fetch('/tdx_feedback_gem/feedbacks', {
    method: 'POST',
    body: formData,
    headers: {
      'X-CSRF-Token': this.getCsrfToken(),
      'Accept': 'application/json'
    }
  })

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`)
  }

  return await response.json()
}
```

#### `getCsrfToken()`
Get CSRF token from meta tag.

```javascript
getCsrfToken() {
  const metaTag = document.querySelector('meta[name="csrf-token"]')
  return metaTag ? metaTag.getAttribute('content') : ''
}
```

### State Management Methods

#### `showLoading()`
Show loading state.

```javascript
showLoading() {
  if (this.loadingTarget) {
    this.loadingTarget.classList.add('show')
  }

  if (this.submitButtonTarget) {
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = 'Submitting...'
  }
}
```

#### `hideLoading()`
Hide loading state.

```javascript
hideLoading() {
  if (this.loadingTarget) {
    this.loadingTarget.classList.remove('show')
  }

  if (this.submitButtonTarget) {
    this.submitButtonTarget.disabled = false
    this.submitButtonTarget.textContent = 'Submit Feedback'
  }
}
```

#### `showSuccess(message)`
Show success message.

```javascript
showSuccess(message) {
  if (this.successTarget) {
    this.successTarget.textContent = message
    this.successTarget.classList.add('show')

    // Auto-hide after 3 seconds
    setTimeout(() => {
      this.successTarget.classList.remove('show')
    }, 3000)
  }
}
```

#### `showError(message)`
Show error message.

```javascript
showError(message) {
  if (this.errorTarget) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.add('show')

    // Auto-hide after 5 seconds
    setTimeout(() => {
      this.errorTarget.classList.remove('show')
    }, 5000)
  }
}
```

#### `showValidationErrors(errors)`
Show validation errors for specific fields.

```javascript
showValidationErrors(errors) {
  // Clear previous errors
  this.clearErrors()

  // Show new errors
  Object.entries(errors).forEach(([field, message]) => {
    const fieldElement = this[`${field}Target`]
    if (fieldElement) {
      // Add error class
      fieldElement.classList.add('error')

      // Show error message
      const errorElement = this.createErrorElement(message)
      fieldElement.parentNode.appendChild(errorElement)
    }
  })
}
```

#### `clearErrors()`
Clear all error messages and states.

```javascript
clearErrors() {
  // Remove error classes
  this.messageTarget?.classList.remove('error')
  this.contextTarget?.classList.remove('error')

  // Remove error messages
  const errorElements = this.element.querySelectorAll('.field-error')
  errorElements.forEach(element => element.remove())

  // Clear general error
  if (this.errorTarget) {
    this.errorTarget.classList.remove('show')
  }
}
```

## 🎪 Events

### Custom Events Dispatched

| Event | Description | Detail |
|-------|-------------|--------|
| `modalOpened` | Modal opened successfully | `{ feedbackType, pageUrl }` |
| `modalClosed` | Modal closed successfully | `{}` |
| `feedbackSubmitted` | Feedback submitted successfully | `{ feedback, ticketId }` |
| `validationFailed` | Form validation failed | `{ errors }` |
| `submissionStarted` | Form submission started | `{}` |
| `submissionCompleted` | Form submission completed | `{ success, response }` |

### Event Usage Examples

```javascript
// Listen for modal events
document.addEventListener('tdx-feedback:modalOpened', (event) => {
  console.log('Modal opened:', event.detail)

  // Track analytics
  analytics.track('Feedback Modal Opened', {
    feedbackType: event.detail.feedbackType,
    pageUrl: event.detail.pageUrl
  })
})

// Listen for submission events
document.addEventListener('tdx-feedback:feedbackSubmitted', (event) => {
  console.log('Feedback submitted:', event.detail)

  // Track success
  analytics.track('Feedback Submitted', {
    feedbackId: event.detail.feedback.id,
    ticketId: event.detail.ticketId
  })

  // Show success notification
  showNotification('Feedback submitted successfully!')
})

// Listen for validation events
document.addEventListener('tdx-feedback:validationFailed', (event) => {
  console.log('Validation failed:', event.detail.errors)

  // Track validation errors
  analytics.track('Feedback Validation Failed', {
    errors: Object.keys(event.detail.errors)
  })
})
```

### Event Dispatching

```javascript
// Dispatch custom events
this.dispatch('modalOpened', {
  detail: {
    feedbackType: this.feedbackTypeValue,
    pageUrl: this.pageUrlValue
  }
})

// Dispatch with bubbles
this.dispatch('feedbackSubmitted', {
  detail: { feedback: response.feedback },
  bubbles: true
})

// Dispatch with cancelable
this.dispatch('submissionStarted', {
  cancelable: true
})
```

## 🔧 Configuration

### Controller Configuration

```javascript
// app/javascript/controllers/tdx_feedback_controller.js
export default class extends Controller {
  static targets = ["modal", "form", "message", "context", "submitButton"]
  static values = {
    autoOpen: Boolean,
    feedbackType: { type: String, default: 'general' },
    pageUrl: { type: String, default: window.location.href },
    userId: String,
    debug: { type: Boolean, default: false },
    animation: { type: Boolean, default: true },
    closeOnOverlay: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true },
    submitUrl: { type: String, default: '/tdx_feedback_gem/feedbacks' },
    maxMessageLength: { type: Number, default: 10000 },
    maxContextLength: { type: Number, default: 10000 }
  }

  // ... rest of controller
}
```

### Configuration Usage

```html
<!-- Configure controller behavior -->
<div
  data-controller="tdx-feedback"
  data-tdx-feedback-feedback-type-value="bug"
  data-tdx-feedback-debug-value="true"
  data-tdx-feedback-animation-value="false"
  data-tdx-feedback-close-on-overlay-value="false"
  data-tdx-feedback-max-message-length-value="5000"
>
  <button data-action="click->tdx-feedback#openModal">Report Bug</button>
</div>
```

## 🎨 Styling and Theming

### CSS Classes Applied

| Class | Applied When | Description |
|-------|--------------|-------------|
| `show` | Modal is open | Shows the modal |
| `error` | Field has validation error | Highlights error state |
| `loading` | Form is submitting | Shows loading state |
| `success` | Operation completed successfully | Shows success state |
| `disabled` | Button is disabled | Disables interaction |

### Custom Styling

```css
/* Custom modal styles */
.tdx-feedback-modal {
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.tdx-feedback-modal.show {
  opacity: 1;
  visibility: visible;
}

/* Custom error styles */
.tdx-feedback-form .error {
  border-color: #dc3545;
  box-shadow: 0 0 0 0.2rem rgba(220, 53, 69, 0.25);
}

/* Custom loading styles */
.tdx-feedback-loading {
  display: none;
}

.tdx-feedback-loading.show {
  display: block;
}

/* Custom success styles */
.tdx-feedback-success {
  display: none;
  color: #28a745;
}

.tdx-feedback-success.show {
  display: block;
}
```

## 🔄 Lifecycle Hooks

### Controller Lifecycle

```javascript
export default class extends Controller {
  // Called when controller connects
  connect() {
    this.setupEventListeners()
    this.initializeModal()
  }

  // Called when controller disconnects
  disconnect() {
    this.cleanupEventListeners()
    this.closeModal()
  }

  // Called when values change
  feedbackTypeValueChanged() {
    if (this.debugValue) {
      console.log('Feedback type changed to:', this.feedbackTypeValue)
    }

    // Update form or UI as needed
    this.updateFormForType()
  }

  // Called when targets change
  modalTargetConnected() {
    if (this.debugValue) {
      console.log('Modal target connected')
    }
  }

  modalTargetDisconnected() {
    if (this.debugValue) {
      console.log('Modal target disconnected')
    }
  }
}
```

## 🧪 Testing

### Controller Testing

```javascript
// spec/javascript/controllers/tdx_feedback_controller_spec.js
import { Application } from "@hotwired/stimulus"
import TdxFeedbackController from "controllers/tdx_feedback_controller"

describe("TdxFeedbackController", () => {
  let application
  let controller
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("tdx-feedback", TdxFeedbackController)

    element = document.createElement("div")
    element.setAttribute("data-controller", "tdx-feedback")
    element.innerHTML = `
      <div data-tdx-feedback-target="modal">
        <form data-tdx-feedback-target="form">
          <textarea data-tdx-feedback-target="message"></textarea>
          <button data-tdx-feedback-target="submitButton">Submit</button>
        </form>
      </div>
    `

    document.body.appendChild(element)
    controller = application.getControllerForElementAndIdentifier(element, "tdx-feedback")
  })

  afterEach(() => {
    document.body.removeChild(element)
    application.stop()
  })

  describe("openModal", () => {
    it("opens the modal", () => {
      controller.openModal()
      expect(controller.modalTarget.classList.contains("show")).toBe(true)
    })
  })

  describe("closeModal", () => {
    it("closes the modal", () => {
      controller.openModal()
      controller.closeModal()
      expect(controller.modalTarget.classList.contains("show")).toBe(false)
    })
  })

  describe("submitForm", () => {
    it("submits the form", async () => {
      // Mock fetch
      global.fetch = jest.fn(() =>
        Promise.resolve({
          ok: true,
          json: () => Promise.resolve({ success: true })
        })
      )

      const event = new Event("submit")
      await controller.submitForm(event)

      expect(fetch).toHaveBeenCalledWith("/tdx_feedback_gem/feedbacks", expect.any(Object))
    })
  })
})
```

## 🔄 Next Steps

Now that you understand the Stimulus API:

1. **[Styling and Theming](Styling-and-Theming)** - Customize the appearance
2. **[Integration Examples](Integration-Examples)** - See real-world usage
3. **[Testing Guide](Testing)** - Test your Stimulus integration
4. **[Performance Optimization](Performance-Optimization)** - Optimize controller performance

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more details about styling and theming, see the [Styling and Theming](Styling-and-Theming) guide.*
