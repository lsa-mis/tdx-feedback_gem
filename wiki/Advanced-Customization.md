Complete guide to advanced customization of the TDX Feedback Gem, including Stimulus controller extension, custom events, analytics integration, and advanced theming.

## 📋 Overview

This guide covers advanced customization techniques for the TDX Feedback Gem, allowing you to extend functionality, integrate with analytics, and create custom themes beyond the basic configuration options.

## 🎮 Stimulus Controller Extension

### Extending the Base Controller

```javascript
// app/javascript/controllers/custom_feedback_controller.js
import TdxFeedbackController from './tdx_feedback_controller'

export default class extends TdxFeedbackController {
  static targets = [...TdxFeedbackController.targets, "analytics", "customField"]
  static values = {
    ...TdxFeedbackController.values,
    analyticsEnabled: { type: Boolean, default: true },
    customTheme: { type: String, default: 'default' }
  }

  connect() {
    super.connect()
    this.initializeCustomFeatures()
  }

  initializeCustomFeatures() {
    // Add custom initialization logic
    this.setupAnalytics()
    this.applyCustomTheme()
    this.setupCustomValidation()
  }

  // Override existing methods
  async submitForm(event) {
    // Track form submission start
    this.trackEvent('feedback_submission_started')

    // Call parent method
    const result = await super.submitForm(event)

    // Track form submission result
    if (result) {
      this.trackEvent('feedback_submission_success')
    } else {
      this.trackEvent('feedback_submission_failed')
    }

    return result
  }

  // Add custom methods
  setupAnalytics() {
    if (this.analyticsEnabledValue) {
      this.trackEvent('feedback_modal_initialized')
    }
  }

  applyCustomTheme() {
    if (this.customThemeValue !== 'default') {
      this.modalTarget.classList.add(`theme-${this.customThemeValue}`)
    }
  }

  setupCustomValidation() {
    // Add custom validation rules
    this.messageTarget.addEventListener('input', this.validateCustomRules.bind(this))
  }

  validateCustomRules(event) {
    const value = event.target.value

    // Custom validation: check for profanity
    if (this.containsProfanity(value)) {
      this.showCustomError('Please avoid inappropriate language')
      return false
    }

    // Custom validation: check for spam patterns
    if (this.isSpam(value)) {
      this.showCustomError('This looks like spam. Please provide meaningful feedback.')
      return false
    }

    return true
  }

  containsProfanity(text) {
    const profanityList = ['bad_word1', 'bad_word2'] // Define your list
    return profanityList.some(word => text.toLowerCase().includes(word))
  }

  isSpam(text) {
    // Check for repetitive characters
    const repetitivePattern = /(.)\1{5,}/
    return repetitivePattern.test(text)
  }

  showCustomError(message) {
    // Create custom error display
    const errorElement = document.createElement('div')
    errorElement.className = 'custom-error'
    errorElement.textContent = message

    this.messageTarget.parentNode.appendChild(errorElement)

    // Auto-remove after 5 seconds
    setTimeout(() => {
      errorElement.remove()
    }, 5000)
  }
}
```

### Custom Controller Registration

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"
import CustomFeedbackController from "./custom_feedback_controller"

// Register custom controller
application.register("custom-feedback", CustomFeedbackController)

// Or register with a different name
application.register("enhanced-feedback", CustomFeedbackController)
```

### Usage in HTML

```html
<!-- Use custom controller -->
<div
  data-controller="custom-feedback"
  data-custom-feedback-analytics-enabled-value="true"
  data-custom-feedback-custom-theme-value="dark"
>
  <button data-action="click->custom-feedback#openModal">Enhanced Feedback</button>
</div>
```

## 🎪 Custom Events and Hooks

### Event System Architecture

```javascript
// app/javascript/controllers/feedback_event_system.js
export default class extends Controller {
  static targets = ["eventLogger"]

  connect() {
    this.setupEventListeners()
  }

  setupEventListeners() {
    // Listen for all feedback events
    document.addEventListener('tdx-feedback:modalOpened', this.handleModalOpened.bind(this))
    document.addEventListener('tdx-feedback:modalClosed', this.handleModalClosed.bind(this))
    document.addEventListener('tdx-feedback:feedbackSubmitted', this.handleFeedbackSubmitted.bind(this))
    document.addEventListener('tdx-feedback:validationFailed', this.handleValidationFailed.bind(this))

    // Listen for custom events
    document.addEventListener('custom-feedback:customEvent', this.handleCustomEvent.bind(this))
  }

  handleModalOpened(event) {
    this.logEvent('Modal Opened', event.detail)
    this.triggerAnalytics('modal_opened', event.detail)
    this.updateUI('modal_opened')
  }

  handleModalClosed(event) {
    this.logEvent('Modal Closed', event.detail)
    this.triggerAnalytics('modal_closed', event.detail)
    this.updateUI('modal_closed')
  }

  handleFeedbackSubmitted(event) {
    this.logEvent('Feedback Submitted', event.detail)
    this.triggerAnalytics('feedback_submitted', event.detail)
    this.updateUI('feedback_submitted')

    // Trigger custom workflow
    this.triggerCustomWorkflow(event.detail)
  }

  handleValidationFailed(event) {
    this.logEvent('Validation Failed', event.detail)
    this.triggerAnalytics('validation_failed', event.detail)
    this.updateUI('validation_failed')
  }

  handleCustomEvent(event) {
    this.logEvent('Custom Event', event.detail)
    this.triggerAnalytics('custom_event', event.detail)
  }

  logEvent(eventName, details) {
    if (this.hasEventLoggerTarget) {
      const timestamp = new Date().toISOString()
      const logEntry = `[${timestamp}] ${eventName}: ${JSON.stringify(details)}`

      this.eventLoggerTarget.textContent += logEntry + '\n'
    }
  }

  triggerAnalytics(eventName, details) {
    // Google Analytics
    if (typeof gtag !== 'undefined') {
      gtag('event', eventName, details)
    }

    // Mixpanel
    if (typeof mixpanel !== 'undefined') {
      mixpanel.track(eventName, details)
    }

    // Custom analytics
    if (typeof customAnalytics !== 'undefined') {
      customAnalytics.track(eventName, details)
    }
  }

  updateUI(state) {
    // Update UI based on event state
    const body = document.body

    switch (state) {
      case 'modal_opened':
        body.classList.add('feedback-modal-open')
        break
      case 'modal_closed':
        body.classList.remove('feedback-modal-open')
        break
      case 'feedback_submitted':
        this.showSuccessNotification()
        break
      case 'validation_failed':
        this.showErrorNotification()
        break
    }
  }

  triggerCustomWorkflow(details) {
    // Custom workflow logic
    if (details.feedbackType === 'bug') {
      this.triggerBugReportWorkflow(details)
    } else if (details.feedbackType === 'feature') {
      this.triggerFeatureRequestWorkflow(details)
    }
  }

  triggerBugReportWorkflow(details) {
    // Send to bug tracking system
    this.sendToBugTracker(details)

    // Notify development team
    this.notifyDevelopmentTeam(details)
  }

  triggerFeatureRequestWorkflow(details) {
    // Send to product management
    this.sendToProductManagement(details)

    // Add to feature backlog
    this.addToFeatureBacklog(details)
  }
}
```

### Custom Event Dispatching

```javascript
// app/javascript/controllers/feedback_workflow.js
export default class extends Controller {
  static targets = ["workflowStatus"]

  // Dispatch custom events
  dispatchWorkflowEvent(eventName, details) {
    const event = new CustomEvent(`feedback-workflow:${eventName}`, {
      detail: details,
      bubbles: true,
      cancelable: true
    })

    document.dispatchEvent(event)
    return event
  }

  // Workflow methods
  startFeedbackWorkflow(feedbackType) {
    const event = this.dispatchWorkflowEvent('workflowStarted', {
      feedbackType,
      timestamp: new Date().toISOString(),
      userId: this.getCurrentUserId()
    })

    if (!event.defaultPrevented) {
      this.updateWorkflowStatus('started')
    }
  }

  completeFeedbackWorkflow(feedbackId) {
    const event = this.dispatchWorkflowEvent('workflowCompleted', {
      feedbackId,
      timestamp: new Date().toISOString(),
      duration: this.calculateWorkflowDuration()
    })

    if (!event.defaultPrevented) {
      this.updateWorkflowStatus('completed')
    }
  }

  updateWorkflowStatus(status) {
    if (this.hasWorkflowStatusTarget) {
      this.workflowStatusTarget.textContent = `Workflow: ${status}`
      this.workflowStatusTarget.className = `workflow-status workflow-${status}`
    }
  }
}
```

## 📊 Analytics Integration

### Google Analytics Integration

```javascript
// app/javascript/controllers/feedback_analytics.js
export default class extends Controller {
  static targets = ["analyticsDebug"]
  static values = {
    trackingId: String,
    enableDebug: { type: Boolean, default: false }
  }

  connect() {
    this.initializeGoogleAnalytics()
    this.setupEventTracking()
  }

  initializeGoogleAnalytics() {
    if (this.trackingIdValue && typeof gtag !== 'undefined') {
      gtag('config', this.trackingIdValue, {
        custom_map: {
          'custom_parameter_1': 'feedback_type',
          'custom_parameter_2': 'feedback_source',
          'custom_parameter_3': 'user_role'
        }
      })
    }
  }

  setupEventTracking() {
    // Track modal interactions
    document.addEventListener('tdx-feedback:modalOpened', (event) => {
      this.trackEvent('feedback_modal_opened', {
        feedback_type: event.detail.feedbackType,
        page_url: event.detail.pageUrl,
        user_id: this.getCurrentUserId()
      })
    })

    // Track form submissions
    document.addEventListener('tdx-feedback:feedbackSubmitted', (event) => {
      this.trackEvent('feedback_submitted', {
        feedback_id: event.detail.feedback.id,
        feedback_type: event.detail.feedback.feedback_type,
        has_context: !!event.detail.feedback.context,
        tdx_ticket_created: !!event.detail.ticketId
      })
    })

    // Track validation failures
    document.addEventListener('tdx-feedback:validationFailed', (event) => {
      this.trackEvent('feedback_validation_failed', {
        errors: Object.keys(event.detail.errors),
        feedback_type: this.getCurrentFeedbackType()
      })
    })
  }

  trackEvent(eventName, parameters) {
    if (typeof gtag !== 'undefined') {
      gtag('event', eventName, {
        ...parameters,
        custom_parameter_1: parameters.feedback_type,
        custom_parameter_2: window.location.pathname,
        custom_parameter_3: this.getCurrentUserRole()
      })

      if (this.enableDebugValue) {
        this.logAnalyticsEvent(eventName, parameters)
      }
    }
  }

  logAnalyticsEvent(eventName, parameters) {
    if (this.hasAnalyticsDebugTarget) {
      const timestamp = new Date().toISOString()
      const logEntry = `[${timestamp}] GA Event: ${eventName} - ${JSON.stringify(parameters)}`

      this.analyticsDebugTarget.textContent += logEntry + '\n'
    }
  }

  // Enhanced tracking methods
  trackUserJourney(step, details) {
    this.trackEvent('user_journey', {
      step,
      ...details,
      session_id: this.getSessionId()
    })
  }

  trackPerformanceMetric(metric, value) {
    this.trackEvent('performance_metric', {
      metric_name: metric,
      metric_value: value,
      page_url: window.location.href
    })
  }

  trackError(error, context) {
    this.trackEvent('feedback_error', {
      error_message: error.message,
      error_stack: error.stack,
      context,
      user_agent: navigator.userAgent
    })
  }
}
```

### Mixpanel Integration

```javascript
// app/javascript/controllers/mixpanel_analytics.js
export default class extends Controller {
  static targets = ["mixpanelDebug"]
  static values = {
    projectToken: String,
    enableDebug: { type: Boolean, default: false }
  }

  connect() {
    this.initializeMixpanel()
    this.setupMixpanelTracking()
  }

  initializeMixpanel() {
    if (this.projectTokenValue && typeof mixpanel !== 'undefined') {
      mixpanel.init(this.projectTokenValue, {
        debug: this.enableDebugValue,
        track_pageview: true,
        persistence: 'localStorage'
      })

      // Set user properties
      this.setUserProperties()
    }
  }

  setUserProperties() {
    const userProperties = {
      $email: this.getCurrentUserEmail(),
      $name: this.getCurrentUserName(),
      user_role: this.getCurrentUserRole(),
      feedback_enabled: true,
      last_visit: new Date().toISOString()
    }

    mixpanel.people.set(userProperties)
  }

  setupMixpanelTracking() {
    // Track feedback events
    document.addEventListener('tdx-feedback:modalOpened', (event) => {
      this.trackEvent('Feedback Modal Opened', {
        'Feedback Type': event.detail.feedbackType,
        'Page URL': event.detail.pageUrl,
        'User ID': this.getCurrentUserId()
      })
    })

    document.addEventListener('tdx-feedback:feedbackSubmitted', (event) => {
      this.trackEvent('Feedback Submitted', {
        'Feedback ID': event.detail.feedback.id,
        'Feedback Type': event.detail.feedback.feedback_type,
        'Has Context': !!event.detail.feedback.context,
        'TDX Ticket Created': !!event.detail.ticketId,
        'Submission Time': new Date().toISOString()
      })
    }
  }

  trackEvent(eventName, properties) {
    if (typeof mixpanel !== 'undefined') {
      mixpanel.track(eventName, {
        ...properties,
        'Page URL': window.location.href,
        'User Agent': navigator.userAgent,
        'Timestamp': new Date().toISOString()
      })

      if (this.enableDebugValue) {
        this.logMixpanelEvent(eventName, properties)
      }
    }
  }

  logMixpanelEvent(eventName, properties) {
    if (this.hasMixpanelDebugTarget) {
      const timestamp = new Date().toISOString()
      const logEntry = `[${timestamp}] Mixpanel Event: ${eventName} - ${JSON.stringify(properties)}`

      this.mixpanelDebugTarget.textContent += logEntry + '\n'
    }
  }
}
```

## 🎨 Advanced Theming

### CSS Custom Properties System

```css
/* app/assets/stylesheets/tdx_feedback_gem/_custom_properties.css */
:root {
  /* Color System */
  --tdx-feedback-primary-color: #007bff;
  --tdx-feedback-secondary-color: #6c757d;
  --tdx-feedback-success-color: #28a745;
  --tdx-feedback-danger-color: #dc3545;
  --tdx-feedback-warning-color: #ffc107;
  --tdx-feedback-info-color: #17a2b8;

  /* Typography */
  --tdx-feedback-font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --tdx-feedback-font-size-base: 1rem;
  --tdx-feedback-font-size-sm: 0.875rem;
  --tdx-feedback-font-size-lg: 1.125rem;
  --tdx-feedback-line-height: 1.5;

  /* Spacing */
  --tdx-feedback-spacing-xs: 0.25rem;
  --tdx-feedback-spacing-sm: 0.5rem;
  --tdx-feedback-spacing-md: 1rem;
  --tdx-feedback-spacing-lg: 1.5rem;
  --tdx-feedback-spacing-xl: 3rem;

  /* Border Radius */
  --tdx-feedback-border-radius: 0.375rem;
  --tdx-feedback-border-radius-sm: 0.25rem;
  --tdx-feedback-border-radius-lg: 0.5rem;

  /* Shadows */
  --tdx-feedback-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  --tdx-feedback-shadow-lg: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);

  /* Transitions */
  --tdx-feedback-transition: all 0.15s ease-in-out;
  --tdx-feedback-transition-fast: all 0.1s ease-in-out;
  --tdx-feedback-transition-slow: all 0.3s ease-in-out;
}

/* Theme Variations */
.theme-dark {
  --tdx-feedback-primary-color: #0d6efd;
  --tdx-feedback-secondary-color: #adb5bd;
  --tdx-feedback-bg-color: #212529;
  --tdx-feedback-text-color: #f8f9fa;
  --tdx-feedback-border-color: #495057;
}

.theme-high-contrast {
  --tdx-feedback-primary-color: #000000;
  --tdx-feedback-secondary-color: #333333;
  --tdx-feedback-bg-color: #ffffff;
  --tdx-feedback-text-color: #000000;
  --tdx-feedback-border-color: #000000;
}

.theme-corporate {
  --tdx-feedback-primary-color: #2c3e50;
  --tdx-feedback-secondary-color: #34495e;
  --tdx-feedback-bg-color: #ecf0f1;
  --tdx-feedback-text-color: #2c3e50;
  --tdx-feedback-border-color: #bdc3c7;
}
```

### Advanced CSS Architecture

```css
/* app/assets/stylesheets/tdx_feedback_gem/_advanced_themes.css */
/* Component-Based Architecture */
.tdx-feedback-component {
  /* Base component styles */
  font-family: var(--tdx-feedback-font-family);
  font-size: var(--tdx-feedback-font-size-base);
  line-height: var(--tdx-feedback-line-height);
  transition: var(--tdx-feedback-transition);
}

/* Modal Component */
.tdx-feedback-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  visibility: hidden;
  transition: var(--tdx-feedback-transition-slow);
}

.tdx-feedback-modal.show {
  opacity: 1;
  visibility: visible;
}

/* Modal Content */
.tdx-feedback-modal-content {
  background: var(--tdx-feedback-bg-color);
  border-radius: var(--tdx-feedback-border-radius-lg);
  box-shadow: var(--tdx-feedback-shadow-lg);
  max-width: 90vw;
  max-height: 90vh;
  overflow: auto;
  position: relative;
  transform: scale(0.9);
  transition: var(--tdx-feedback-transition-slow);
}

.tdx-feedback-modal.show .tdx-feedback-modal-content {
  transform: scale(1);
}

/* Form Component */
.tdx-feedback-form {
  padding: var(--tdx-feedback-spacing-lg);
}

.tdx-feedback-form-group {
  margin-bottom: var(--tdx-feedback-spacing-md);
}

.tdx-feedback-label {
  display: block;
  margin-bottom: var(--tdx-feedback-spacing-sm);
  font-weight: 500;
  color: var(--tdx-feedback-text-color);
}

.tdx-feedback-input {
  width: 100%;
  padding: var(--tdx-feedback-spacing-sm);
  border: 1px solid var(--tdx-feedback-border-color);
  border-radius: var(--tdx-feedback-border-radius);
  font-size: var(--tdx-feedback-font-size-base);
  transition: var(--tdx-feedback-transition-fast);
}

.tdx-feedback-input:focus {
  outline: none;
  border-color: var(--tdx-feedback-primary-color);
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

/* Button Component */
.tdx-feedback-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--tdx-feedback-spacing-sm) var(--tdx-feedback-spacing-md);
  border: 1px solid transparent;
  border-radius: var(--tdx-feedback-border-radius);
  font-size: var(--tdx-feedback-font-size-base);
  font-weight: 500;
  text-decoration: none;
  cursor: pointer;
  transition: var(--tdx-feedback-transition-fast);
}

.tdx-feedback-button-primary {
  background-color: var(--tdx-feedback-primary-color);
  border-color: var(--tdx-feedback-primary-color);
  color: white;
}

.tdx-feedback-button-primary:hover {
  background-color: #0056b3;
  border-color: #0056b3;
}

.tdx-feedback-button-secondary {
  background-color: var(--tdx-feedback-secondary-color);
  border-color: var(--tdx-feedback-secondary-color);
  color: white;
}

/* Responsive Design */
@media (max-width: 768px) {
  .tdx-feedback-modal-content {
    margin: var(--tdx-feedback-spacing-md);
    max-width: calc(100vw - 2rem);
    max-height: calc(100vh - 2rem);
  }

  .tdx-feedback-form {
    padding: var(--tdx-feedback-spacing-md);
  }

  .tdx-feedback-button {
    width: 100%;
    margin-bottom: var(--tdx-feedback-spacing-sm);
  }
}

/* Animation Variants */
.tdx-feedback-modal.slide-in {
  transform: translateY(-100%);
}

.tdx-feedback-modal.slide-in.show {
  transform: translateY(0);
}

.tdx-feedback-modal.fade-in {
  opacity: 0;
}

.tdx-feedback-modal.fade-in.show {
  opacity: 1;
}

.tdx-feedback-modal.zoom-in .tdx-feedback-modal-content {
  transform: scale(0.3);
}

.tdx-feedback-modal.zoom-in.show .tdx-feedback-modal-content {
  transform: scale(1);
}
```

### JavaScript Theme Management

```javascript
// app/javascript/controllers/theme_manager.js
export default class extends Controller {
  static targets = ["themeSelector", "themePreview"]
  static values = {
    currentTheme: { type: String, default: 'default' },
    availableThemes: Array
  }

  connect() {
    this.loadSavedTheme()
    this.setupThemeSelector()
    this.applyTheme(this.currentThemeValue)
  }

  loadSavedTheme() {
    const savedTheme = localStorage.getItem('tdx-feedback-theme')
    if (savedTheme && this.availableThemesValue.includes(savedTheme)) {
      this.currentThemeValue = savedTheme
    }
  }

  setupThemeSelector() {
    if (this.hasThemeSelectorTarget) {
      this.themeSelectorTarget.innerHTML = this.generateThemeOptions()
      this.themeSelectorTarget.addEventListener('change', this.handleThemeChange.bind(this))
    }
  }

  generateThemeOptions() {
    return this.availableThemesValue.map(theme =>
      `<option value="${theme}" ${theme === this.currentThemeValue ? 'selected' : ''}>
        ${this.formatThemeName(theme)}
      </option>`
    ).join('')
  }

  formatThemeName(theme) {
    return theme.split('-').map(word =>
      word.charAt(0).toUpperCase() + word.slice(1)
    ).join(' ')
  }

  handleThemeChange(event) {
    const newTheme = event.target.value
    this.changeTheme(newTheme)
  }

  changeTheme(themeName) {
    if (this.availableThemesValue.includes(themeName)) {
      this.removeCurrentTheme()
      this.applyTheme(themeName)
      this.currentThemeValue = themeName
      this.saveTheme(themeName)
      this.updateThemePreview(themeName)
    }
  }

  removeCurrentTheme() {
    const modal = document.querySelector('.tdx-feedback-modal')
    if (modal) {
      this.availableThemesValue.forEach(theme => {
        modal.classList.remove(`theme-${theme}`)
      })
    }
  }

  applyTheme(themeName) {
    const modal = document.querySelector('.tdx-feedback-modal')
    if (modal && themeName !== 'default') {
      modal.classList.add(`theme-${themeName}`)
    }

    // Apply theme-specific CSS variables
    this.applyThemeVariables(themeName)
  }

  applyThemeVariables(themeName) {
    const root = document.documentElement
    const themeVariables = this.getThemeVariables(themeName)

    Object.entries(themeVariables).forEach(([property, value]) => {
      root.style.setProperty(`--tdx-feedback-${property}`, value)
    })
  }

  getThemeVariables(themeName) {
    const themes = {
      'dark': {
        'primary-color': '#0d6efd',
        'secondary-color': '#adb5bd',
        'bg-color': '#212529',
        'text-color': '#f8f9fa',
        'border-color': '#495057'
      },
      'high-contrast': {
        'primary-color': '#000000',
        'secondary-color': '#333333',
        'bg-color': '#ffffff',
        'text-color': '#000000',
        'border-color': '#000000'
      },
      'corporate': {
        'primary-color': '#2c3e50',
        'secondary-color': '#34495e',
        'bg-color': '#ecf0f1',
        'text-color': '#2c3e50',
        'border-color': '#bdc3c7'
      }
    }

    return themes[themeName] || {}
  }

  saveTheme(themeName) {
    localStorage.setItem('tdx-feedback-theme', themeName)
  }

  updateThemePreview(themeName) {
    if (this.hasThemePreviewTarget) {
      this.themePreviewTarget.className = `theme-preview theme-${themeName}`
      this.themePreviewTarget.textContent = `Theme: ${this.formatThemeName(themeName)}`
    }
  }

  // Theme cycling
  cycleTheme() {
    const currentIndex = this.availableThemesValue.indexOf(this.currentThemeValue)
    const nextIndex = (currentIndex + 1) % this.availableThemesValue.length
    const nextTheme = this.availableThemesValue[nextIndex]

    this.changeTheme(nextTheme)
  }

  // Random theme
  randomTheme() {
    const availableThemes = this.availableThemesValue.filter(theme => theme !== 'default')
    const randomTheme = availableThemes[Math.floor(Math.random() * availableThemes.length)]

    this.changeTheme(randomTheme)
  }
}
```

## 🔧 Custom Validation and Workflows

### Advanced Form Validation

```javascript
// app/javascript/controllers/advanced_validation.js
export default class extends Controller {
  static targets = ["validationRules", "customErrors"]
  static values = {
    validationLevel: { type: String, default: 'standard' },
    enableRealTime: { type: Boolean, default: true }
  }

  connect() {
    this.setupValidationRules()
    if (this.enableRealTimeValue) {
      this.setupRealTimeValidation()
    }
  }

  setupValidationRules() {
    this.validationRules = {
      standard: this.getStandardRules(),
      strict: this.getStrictRules(),
      custom: this.getCustomRules()
    }
  }

  getStandardRules() {
    return {
      message: {
        required: true,
        minLength: 10,
        maxLength: 10000,
        noProfanity: true
      },
      context: {
        required: false,
        maxLength: 10000,
        noSpam: true
      }
    }
  }

  getStrictRules() {
    return {
      message: {
        required: true,
        minLength: 50,
        maxLength: 5000,
        noProfanity: true,
        noSpam: true,
        meaningfulContent: true
      },
      context: {
        required: true,
        minLength: 20,
        maxLength: 5000,
        noSpam: true
      }
    }
  }

  getCustomRules() {
    return {
      message: {
        required: true,
        minLength: 25,
        maxLength: 2000,
        noProfanity: true,
        noSpam: true,
        meaningfulContent: true,
        noRepetitiveText: true,
        noAllCaps: true
      },
      context: {
        required: false,
        maxLength: 2000,
        noSpam: true,
        noRepetitiveText: true
      }
    }
  }

  setupRealTimeValidation() {
    const inputs = this.element.querySelectorAll('input, textarea')

    inputs.forEach(input => {
      input.addEventListener('input', this.validateField.bind(this))
      input.addEventListener('blur', this.validateField.bind(this))
    })
  }

  validateField(event) {
    const field = event.target
    const fieldName = field.name.replace('feedback[', '').replace(']', '')
    const value = field.value
    const rules = this.validationRules[this.validationLevelValue][fieldName]

    if (!rules) return true

    const errors = this.validateFieldValue(value, rules)
    this.displayFieldErrors(field, errors)

    return errors.length === 0
  }

  validateFieldValue(value, rules) {
    const errors = []

    if (rules.required && !value.trim()) {
      errors.push('This field is required')
    }

    if (value.trim()) {
      if (rules.minLength && value.length < rules.minLength) {
        errors.push(`Minimum length is ${rules.minLength} characters`)
      }

      if (rules.maxLength && value.length > rules.maxLength) {
        errors.push(`Maximum length is ${rules.maxLength} characters`)
      }

      if (rules.noProfanity && this.containsProfanity(value)) {
        errors.push('Please avoid inappropriate language')
      }

      if (rules.noSpam && this.isSpam(value)) {
        errors.push('This looks like spam. Please provide meaningful feedback.')
      }

      if (rules.meaningfulContent && !this.hasMeaningfulContent(value)) {
        errors.push('Please provide more meaningful content')
      }

      if (rules.noRepetitiveText && this.hasRepetitiveText(value)) {
        errors.push('Please avoid repetitive text')
      }

      if (rules.noAllCaps && this.isAllCaps(value)) {
        errors.push('Please avoid using all capital letters')
      }
    }

    return errors
  }

  containsProfanity(text) {
    const profanityList = ['bad_word1', 'bad_word2'] // Define your list
    return profanityList.some(word => text.toLowerCase().includes(word))
  }

  isSpam(text) {
    // Check for repetitive characters
    const repetitivePattern = /(.)\1{5,}/
    return repetitivePattern.test(text)
  }

  hasMeaningfulContent(text) {
    // Check for meaningful content (not just repeated words)
    const words = text.trim().split(/\s+/)
    const uniqueWords = new Set(words)
    return uniqueWords.size >= 5
  }

  hasRepetitiveText(text) {
    // Check for repeated phrases
    const phrases = text.split(/[.!?]+/)
    const phraseCounts = {}

    phrases.forEach(phrase => {
      const cleanPhrase = phrase.trim().toLowerCase()
      if (cleanPhrase.length > 10) {
        phraseCounts[cleanPhrase] = (phraseCounts[cleanPhrase] || 0) + 1
      }
    })

    return Object.values(phraseCounts).some(count => count > 2)
  }

  isAllCaps(text) {
    const words = text.trim().split(/\s+/)
    const allCapsWords = words.filter(word => word.length > 2 && word === word.toUpperCase())
    return allCapsWords.length > words.length * 0.3
  }

  displayFieldErrors(field, errors) {
    // Remove existing errors
    this.removeFieldErrors(field)

    // Add new errors
    errors.forEach(error => {
      const errorElement = document.createElement('div')
      errorElement.className = 'field-error'
      errorElement.textContent = error

      field.parentNode.appendChild(errorElement)
    })

    // Update field styling
    if (errors.length > 0) {
      field.classList.add('error')
    } else {
      field.classList.remove('error')
    }
  }

  removeFieldErrors(field) {
    const existingErrors = field.parentNode.querySelectorAll('.field-error')
    existingErrors.forEach(error => error.remove())
  }
}
```

## 🔄 Next Steps

Now that you understand advanced customization:

1. **[Stimulus API Reference](Stimulus-API-Reference)** - Learn the full API
2. **[Development Setup](Development-Setup)** - Set up your development environment
3. **[Contributing Guidelines](Contributing)** - Contribute your customizations
4. **[Performance Optimization](Performance-Optimization)** - Optimize your custom code

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Stimulus API Reference](Stimulus-API-Reference) for controller details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub
- Join the development discussion

---

*For more details about the Stimulus API, see the [Stimulus API Reference](Stimulus-API-Reference) guide.*
