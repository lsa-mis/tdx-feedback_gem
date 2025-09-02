# Stimulus API Reference

Accurate reference for the Stimulus controller shipped with the gem at `app/javascript/controllers/tdx_feedback_controller.js`.

## Overview

The controller fetches the modal HTML over JSON and injects it into the DOM. It also submits the feedback form via XHR and reports success or validation errors.

Default endpoints:

- GET `/tdx_feedback_gem/feedbacks/new` → returns `{ html: "..." }`
- POST `/tdx_feedback_gem/feedbacks` → returns `{ success: true/false, ... }`

## Controller API

### Targets

- `modal` — `#tdx-feedback-modal`
- `overlay` — `#tdx-feedback-modal-overlay`
- `form` — `#tdx-feedback-form`
- `submitButton` — `.tdx-feedback-submit`
- `cancelButton` — `#tdx-feedback-cancel`
- `closeButton` — `#tdx-feedback-modal-close`

### Values

- `isOpen` (Boolean) — modal open state
- `submitUrl` (String) — defaults to `/tdx_feedback_gem/feedbacks`
- `newUrl` (String) — defaults to `/tdx_feedback_gem/feedbacks/new`

### Methods

- `connect()` — initializes defaults and exposes `window.openTdxFeedbackModal`
- `disconnect()` — cleans up global
- `open()` — fetches modal HTML via `newUrl`, injects into DOM, focuses first input, dispatches `tdx-feedback:opened`
- `close()` — hides and removes modal from DOM, dispatches `tdx-feedback:closed`
- `handleSubmit(event)` — posts form data to `submitUrl`, shows success/error, replaces form HTML if provided
- `showMessage(message, type)` — displays a temporary message in the modal body
- `showErrors(errors)` — renders a list of validation errors in the modal body
- `closeOnOverlayClick(event)` — closes when clicking the overlay
- `closeOnEscape(event)` — closes when pressing Escape while open
- `modalTargetConnected()` / `modalTargetDisconnected()` — binds/unbinds modal events
- `bindModalEvents()` / `unbindModalEvents()` — internal helpers for event wiring

### Actions

Use on triggers or elements:

- `click->tdx-feedback#open`
- `click->tdx-feedback#close`
- `submit->tdx-feedback#handleSubmit`
- `click->tdx-feedback#closeOnOverlayClick` (overlay element)

### Minimal trigger example

```erb
<%= feedback_button('Send Feedback') %>
```

### Registering the controller

```javascript
// app/javascript/controllers/index.js
import { application } from "./application"
import TdxFeedbackController from "./tdx_feedback_controller"

application.register("tdx-feedback", TdxFeedbackController)
```

## Notes

- The modal markup is rendered server-side via the `_modal` and `_form` partials and inserted into `document.body`.
- CSRF is handled by Rails; the controller submits `FormData` with the authentic token when present.
- If `require_authentication` is true without a `current_user`, GET/POST will return 401.

## Next Steps

1. [Getting Started](Getting-Started)
2. [Styling and Theming](Styling-and-Theming)
3. [Helper Methods Reference](Helper-Methods-Reference)
