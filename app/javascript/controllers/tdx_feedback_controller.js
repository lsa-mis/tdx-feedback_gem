// TDX Feedback Gem Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "overlay", "form", "submitButton", "cancelButton", "closeButton"]
  static values = {
    isOpen: Boolean,
    submitUrl: String,
    newUrl: String
  }

  connect() {
    this.isOpenValue = false
    this.submitUrlValue = this.submitUrlValue || '/tdx_feedback_gem/feedbacks'
    this.newUrlValue = this.newUrlValue || '/tdx_feedback_gem/feedbacks/new'

    // Bind global function for external access
    window.openTdxFeedbackModal = () => this.open()
  }

  disconnect() {
    // Cleanup global function
    delete window.openTdxFeedbackModal
  }

  // Open the feedback modal
  async open() {
    if (this.isOpenValue) return

    try {
      // Fetch modal content
      const response = await fetch(this.newUrlValue, {
        headers: {
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      if (!response.ok) throw new Error('Failed to fetch modal')

      const data = await response.json()

      // Insert modal into DOM
      document.body.insertAdjacentHTML('beforeend', data.html)

      // Get references to modal elements
      this.modal = document.getElementById('tdx-feedback-modal')
      this.overlay = document.getElementById('tdx-feedback-modal-overlay')
      this.form = document.getElementById('tdx-feedback-form')

      // Show modal
      this.modal.style.display = 'block'
      this.isOpenValue = true

      // Focus on first input
      const firstInput = this.modal.querySelector('input, textarea')
      if (firstInput) firstInput.focus()

      // Add open class for animations
      setTimeout(() => {
        this.modal.classList.add('tdx-feedback-modal-open')
      }, 10)

      // Dispatch custom event
      this.dispatch('opened')

    } catch (error) {
      console.error('Error opening feedback modal:', error)
      alert('Unable to open feedback form. Please try again.')
    }
  }

  // Close the feedback modal
  close() {
    if (!this.isOpenValue || !this.modal) return

    // Remove open class for animations
    this.modal.classList.remove('tdx-feedback-modal-open')

    // Wait for animation, then hide and remove
    setTimeout(() => {
      this.modal.style.display = 'none'
      this.modal.remove()
      this.modal = null
      this.overlay = null
      this.form = null
      this.isOpenValue = false

      // Dispatch custom event
      this.dispatch('closed')
    }, 150)
  }

  // Handle form submission
  async handleSubmit(event) {
    event.preventDefault()

    if (!this.form) return

    const submitButton = this.form.querySelector('.tdx-feedback-submit')
    const originalText = submitButton.textContent

    // Disable form and show loading state
    submitButton.disabled = true
    submitButton.textContent = 'Sending...'

    // Clear previous errors
    const errorContainer = this.form.querySelector('.tdx-feedback-errors')
    if (errorContainer) errorContainer.remove()

    try {
      // Submit form data
      const formData = new FormData(this.form)

      const response = await fetch(this.submitUrlValue, {
        method: 'POST',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })

      const data = await response.json()

      if (data.success) {
        // Show success message
        this.showMessage(data.message, 'success')

        // Close modal after delay
        setTimeout(() => {
          this.close()
        }, 2000)
      } else {
        // Show errors
        this.showErrors(data.errors)

        // Update form with new HTML if provided
        if (data.html) {
          const formContainer = this.form.parentElement
          formContainer.innerHTML = data.html
          this.form = document.getElementById('tdx-feedback-form')
        }
      }
    } catch (error) {
      console.error('Error submitting feedback:', error)
      this.showMessage('An error occurred. Please try again.', 'error')
    } finally {
      // Re-enable form
      submitButton.disabled = false
      submitButton.textContent = originalText
    }
  }

  // Show success/error messages
  showMessage(message, type) {
    const messageDiv = document.createElement('div')
    messageDiv.className = `tdx-feedback-message tdx-feedback-message-${type}`
    messageDiv.textContent = message

    const modalBody = this.modal.querySelector('.tdx-feedback-modal-body')
    modalBody.insertBefore(messageDiv, modalBody.firstChild)

    // Remove message after delay
    setTimeout(() => {
      messageDiv.remove()
    }, 5000)
  }

  // Show validation errors
  showErrors(errors) {
    const errorContainer = document.createElement('div')
    errorContainer.className = 'tdx-feedback-errors'

    const errorList = document.createElement('ul')
    errors.forEach(error => {
      const li = document.createElement('li')
      li.textContent = error
      errorList.appendChild(li)
    })

    errorContainer.appendChild(errorList)

    const modalBody = this.modal.querySelector('.tdx-feedback-modal-body')
    modalBody.insertBefore(errorContainer, modalBody.firstChild)
  }

  // Event handlers
  closeOnOverlayClick(event) {
    if (event.target.id === 'tdx-feedback-modal-overlay') {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === 'Escape' && this.isOpenValue) {
      this.close()
    }
  }

  // Lifecycle callbacks
  modalTargetConnected() {
    // Modal was added to DOM
    this.bindModalEvents()
  }

  modalTargetDisconnected() {
    // Modal was removed from DOM
    this.unbindModalEvents()
  }

  bindModalEvents() {
    if (!this.modal) return

    // Bind form submission
    this.form.addEventListener('submit', this.handleSubmit.bind(this))

    // Bind close button events
    const closeButton = this.modal.querySelector('#tdx-feedback-modal-close')
    const cancelButton = this.modal.querySelector('#tdx-feedback-cancel')

    if (closeButton) {
      closeButton.addEventListener('click', () => this.close())
    }

    if (cancelButton) {
      cancelButton.addEventListener('click', () => this.close())
    }
  }

  unbindModalEvents() {
    if (!this.modal) return

    // Remove event listeners
    this.form.removeEventListener('submit', this.handleSubmit.bind(this))

    const closeButton = this.modal.querySelector('#tdx-feedback-modal-close')
    const cancelButton = this.modal.querySelector('#tdx-feedback-cancel')

    if (closeButton) {
      closeButton.removeEventListener('click', () => this.close())
    }

    if (cancelButton) {
      cancelButton.removeEventListener('click', () => this.close())
    }
  }
}
