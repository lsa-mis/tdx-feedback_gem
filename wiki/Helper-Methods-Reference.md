# Helper Methods Reference

Complete reference for all Rails view helpers provided by the gem. These render triggers and the modal wiring needed by the Stimulus controller.

## Overview

- Triggers open the modal by calling the Stimulus controller (`click->tdx-feedback#open`).
- Modal HTML is fetched from `GET /tdx_feedback_gem/feedbacks/new` (JSON) and injected into `document.body`.
- Form is submitted to `POST /tdx_feedback_gem/feedbacks` (JSON).
- If `require_authentication` is enabled and there is no `current_user`, requests return 401.

## Helpers

### feedback_system(options = {})

Renders the modal (hidden) plus a trigger. Handy drop-in widget.

Options:

- `trigger` Symbol: `:link` (default), `:button`, `:icon`
- `text` String: Trigger label (default "Feedback")
- `class` String: Extra classes for the trigger

Usage:

```erb
<%= feedback_system(trigger: :button, text: 'Send Feedback', class: 'btn btn-primary') %>
```

### feedback_link(text = 'Feedback', options = {})

Renders an anchor trigger.

Default attributes:

- `href="#"`
- `data-controller="tdx-feedback"`
- `data-action="click->tdx-feedback#open"`
- `data-tdx-feedback-target="trigger"`
- `class="tdx-feedback-link"`

Usage:

```erb
<%= feedback_link('Report Issue', class: 'link-small') %>
```

### feedback_button(text = 'Send Feedback', options = {})

Renders a button trigger.

Defaults mirror `feedback_link` with `class="tdx-feedback-button"`.

Usage:

```erb
<%= feedback_button('Feedback', class: 'btn btn-outline-primary') %>
```

### feedback_icon(options = {})

Renders an icon trigger (anchor with inline SVG).

Defaults mirror `feedback_link` with `class="tdx-feedback-icon"`.

Usage:

```erb
<%= feedback_icon(class: 'header-icon') %>
```

### feedback_footer_link

Footer-friendly link with `tdx-feedback-footer-link` class.

Usage:

```erb
<%= feedback_footer_link %>
```

### feedback_header_button

Header-friendly button with `tdx-feedback-header-button` class.

Usage:

```erb
<%= feedback_header_button %>
```

### render_feedback_modal

Renders the modal partial only. Not required when using `feedback_system`.

Usage:

```erb
<%= render_feedback_modal %>
```

### feedback_trigger(options = {})

Flexible trigger that dispatches to link/button/icon based on `type`.

Options:

- `type` Symbol: `:link` (default), `:button`, `:icon`
- `text` String: Trigger label when applicable
- Other options same as `feedback_link`

Usage:

```erb
<%= feedback_trigger(type: :button, text: 'Feedback', class: 'btn-primary') %>
```

## CSS classes

- `tdx-feedback-link`
- `tdx-feedback-button`
- `tdx-feedback-icon`
- `tdx-feedback-footer-link`
- `tdx-feedback-header-button`

Tip: If your app uses SCSS, import `_tdx_feedback_gem.scss` (the engine can copy it into your app) or include the precompiled `tdx_feedback_gem.css`.

## Notes

- Triggers call the Stimulus controller to load and display the modal.
- See [Stimulus API Reference](Stimulus-API-Reference.md) for controller details.
- For integration issues, see [Troubleshooting Guide](Troubleshooting-Guide) and [Testing Guide](Testing-Guide.md).
