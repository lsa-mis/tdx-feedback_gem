# Styling and Theming

Complete guide to customizing the appearance of the TDX Feedback Gem to match your application's design.

## 🎨 CSS Classes Reference

### Modal Structure

```css
.tdx-feedback-modal              /* Modal container (fixed positioning) */
.tdx-feedback-modal-overlay      /* Backdrop overlay */
.tdx-feedback-modal-content      /* Modal content box */
.tdx-feedback-modal-header       /* Modal header with title and close button */
.tdx-feedback-modal-body         /* Modal body containing the form */
.tdx-feedback-modal-close        /* Close button (×) */
```

### Form Elements

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

### States & Messages

```css
.tdx-feedback-modal-open        /* Applied when modal is visible */
.tdx-feedback-errors            /* Error message container */
.tdx-feedback-message           /* Success/error message container */
.tdx-feedback-message-success   /* Success message styling */
.tdx-feedback-message-error     /* Error message styling */
```

### Link & Button Styles

```css
.tdx-feedback-link              /* Feedback links */
.tdx-feedback-button            /* Feedback buttons */
.tdx-feedback-icon              /* Icon links */
.tdx-feedback-footer-link       /* Footer-specific styling */
.tdx-feedback-header-button     /* Header-specific styling */
```

## 🎭 Theme Examples

### Dark Theme

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

.tdx-feedback-cancel:hover {
  background: #4b5563;
}
```

### Gradient Theme

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

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  border-color: rgba(255, 255, 255, 0.8);
  box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.1);
}

.tdx-feedback-submit {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.tdx-feedback-submit:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.3);
}

.tdx-feedback-cancel {
  background: transparent;
  color: white;
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.tdx-feedback-cancel:hover {
  background: rgba(255, 255, 255, 0.1);
}
```

### Minimal Theme

```css
/* Minimal, borderless design */
.tdx-feedback-modal-content {
  background: white;
  border: 1px solid #e5e7eb;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
}

.tdx-feedback-modal-header {
  border-bottom: 1px solid #f3f4f6;
}

.tdx-feedback-input,
.tdx-feedback-textarea {
  border: none;
  border-bottom: 1px solid #e5e7eb;
  border-radius: 0;
  background: transparent;
  padding: 12px 0;
}

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  border-bottom-color: #3b82f6;
  box-shadow: none;
  outline: none;
}

.tdx-feedback-submit {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-weight: 500;
}

.tdx-feedback-submit:hover:not(:disabled) {
  background: #2563eb;
}

.tdx-feedback-cancel {
  background: transparent;
  color: #6b7280;
  border: 1px solid #d1d5db;
  padding: 12px 24px;
  border-radius: 6px;
}

.tdx-feedback-cancel:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}
```

### Bootstrap Theme

```css
/* Bootstrap-compatible theme */
.tdx-feedback-modal-content {
  background: white;
  border-radius: 0.375rem;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.tdx-feedback-modal-header {
  border-bottom: 1px solid #dee2e6;
  padding: 1rem 1.5rem;
}

.tdx-feedback-modal-header h3 {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 500;
}

.tdx-feedback-modal-body {
  padding: 1.5rem;
}

.tdx-feedback-input,
.tdx-feedback-textarea {
  display: block;
  width: 100%;
  padding: 0.375rem 0.75rem;
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
  color: #212529;
  background-color: #fff;
  background-clip: padding-box;
  border: 1px solid #ced4da;
  border-radius: 0.375rem;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  color: #212529;
  background-color: #fff;
  border-color: #86b7fe;
  outline: 0;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.tdx-feedback-submit {
  display: inline-block;
  font-weight: 400;
  line-height: 1.5;
  color: #fff;
  text-align: center;
  text-decoration: none;
  vertical-align: middle;
  cursor: pointer;
  user-select: none;
  background-color: #0d6efd;
  border: 1px solid #0d6efd;
  padding: 0.375rem 0.75rem;
  font-size: 1rem;
  border-radius: 0.375rem;
  transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out, border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.tdx-feedback-submit:hover:not(:disabled) {
  color: #fff;
  background-color: #0b5ed7;
  border-color: #0a58ca;
}

.tdx-feedback-cancel {
  display: inline-block;
  font-weight: 400;
  line-height: 1.5;
  color: #6c757d;
  text-align: center;
  text-decoration: none;
  vertical-align: middle;
  cursor: pointer;
  user-select: none;
  background-color: #fff;
  border: 1px solid #6c757d;
  padding: 0.375rem 0.75rem;
  font-size: 1rem;
  border-radius: 0.375rem;
  transition: color 0.15s ease-in-out, background-color 0.15s ease-in-out, border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.tdx-feedback-cancel:hover {
  color: #fff;
  background-color: #6c757d;
  border-color: #6c757d;
}
```

## 📱 Responsive Design

### Mobile-First Approach

```css
/* Base styles for mobile */
.tdx-feedback-modal-content {
  width: 95%;
  margin: 20px;
  max-height: calc(100vh - 40px);
  overflow-y: auto;
}

.tdx-feedback-actions {
  flex-direction: column;
  gap: 12px;
}

.tdx-feedback-submit,
.tdx-feedback-cancel {
  width: 100%;
  text-align: center;
}

/* Tablet and up */
@media (min-width: 768px) {
  .tdx-feedback-modal-content {
    width: 600px;
    margin: 40px auto;
  }

  .tdx-feedback-actions {
    flex-direction: row;
    justify-content: flex-end;
    gap: 12px;
  }

  .tdx-feedback-submit,
  .tdx-feedback-cancel {
    width: auto;
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .tdx-feedback-modal-content {
    width: 700px;
    margin: 60px auto;
  }
}
```

### Touch-Friendly Design

```css
/* Touch-friendly button sizes */
.tdx-feedback-submit,
.tdx-feedback-cancel {
  min-height: 44px; /* iOS minimum touch target */
  padding: 12px 24px;
}

.tdx-feedback-modal-close {
  width: 44px;
  height: 44px;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* Touch-friendly form inputs */
.tdx-feedback-input,
.tdx-feedback-textarea {
  min-height: 44px;
  font-size: 16px; /* Prevents zoom on iOS */
}
```

## 🎨 Custom Button Styles

### Primary Button Variants

```css
/* Primary button with different styles */
.tdx-feedback-submit.btn-primary {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s;
}

.tdx-feedback-submit.btn-primary:hover:not(:disabled) {
  background: #2563eb;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}

.tdx-feedback-submit.btn-primary:active {
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(59, 130, 246, 0.3);
}
```

### Outline Button Variants

```css
/* Outline button styles */
.tdx-feedback-submit.btn-outline-primary {
  background: transparent;
  color: #3b82f6;
  border: 2px solid #3b82f6;
  padding: 10px 22px; /* Compensate for border */
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s;
}

.tdx-feedback-submit.btn-outline-primary:hover:not(:disabled) {
  background: #3b82f6;
  color: white;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
}
```

### Rounded Button Variants

```css
/* Rounded button styles */
.tdx-feedback-submit.btn-rounded {
  border-radius: 50px;
  padding: 12px 32px;
  font-weight: 600;
  letter-spacing: 0.5px;
  text-transform: uppercase;
  font-size: 0.875rem;
}

.tdx-feedback-submit.btn-rounded:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}
```

## 🔧 Custom Feedback Links

### Link Styles

```css
/* Custom feedback link styles */
.tdx-feedback-link {
  color: #6b7280;
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 6px;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.tdx-feedback-link:hover {
  color: #3b82f6;
  background: #f3f4f6;
  text-decoration: none;
}

.tdx-feedback-link:active {
  transform: scale(0.98);
}
```

### Button Styles

```css
/* Custom feedback button styles */
.tdx-feedback-button {
  background: #f3f4f6;
  border: 1px solid #d1d5db;
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 500;
  transition: all 0.2s;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.tdx-feedback-button:hover {
  background: #e5e7eb;
  border-color: #9ca3af;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.tdx-feedback-button:active {
  transform: translateY(0);
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
}
```

### Icon Styles

```css
/* Custom feedback icon styles */
.tdx-feedback-icon {
  color: #6b7280;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: transparent;
}

.tdx-feedback-icon:hover {
  color: #3b82f6;
  background: #f3f4f6;
  transform: scale(1.1);
}

.tdx-feedback-icon:active {
  transform: scale(0.95);
}
```

## 🎭 Icon Customization

### SVG Icon Styling

```css
/* Custom icon color and size */
.tdx-feedback-icon-svg {
  width: 24px;
  height: 24px;
  fill: currentColor;
  transition: all 0.2s;
}

/* Custom icon colors */
.tdx-feedback-icon.primary {
  color: #3b82f6;
}

.tdx-feedback-icon.secondary {
  color: #6b7280;
}

.tdx-feedback-icon.success {
  color: #10b981;
}

.tdx-feedback-icon.warning {
  color: #f59e0b;
}

.tdx-feedback-icon.danger {
  color: #ef4444;
}
```

### Custom Icon Replacement

```css
/* Replace default icon with custom icon */
.tdx-feedback-icon::before {
  content: "💬"; /* Unicode emoji */
  font-size: 20px;
}

/* Or use a custom font icon */
.tdx-feedback-icon::before {
  content: "\f075"; /* FontAwesome comment icon */
  font-family: "Font Awesome 5 Free";
  font-weight: 900;
}
```

## 🎨 Animation and Transitions

### Modal Animations

```css
/* Smooth modal entrance */
.tdx-feedback-modal {
  transition: transform 0.3s ease-out, opacity 0.3s ease-out;
  transform: translateY(-20px);
  opacity: 0;
}

.tdx-feedback-modal.show {
  transform: translateY(0);
  opacity: 1;
}

/* Hardware acceleration for smooth animations */
.tdx-feedback-modal {
  will-change: transform, opacity;
  transform: translateZ(0);
}
```

### Button Hover Effects

```css
/* Button hover animations */
.tdx-feedback-submit {
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
}

.tdx-feedback-submit:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.tdx-feedback-submit:active {
  transform: translateY(0);
  transition: all 0.1s;
}
```

### Form Field Focus Effects

```css
/* Form field focus animations */
.tdx-feedback-input,
.tdx-feedback-textarea {
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
  transform: scale(1.01);
  transition: all 0.2s ease;
}
```

## 🎯 Layout Customization

### Modal Positioning

```css
/* Custom modal positioning */
.tdx-feedback-modal {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.tdx-feedback-modal-content {
  max-width: 90vw;
  max-height: 90vh;
  overflow-y: auto;
}

/* Center modal on mobile */
@media (max-width: 640px) {
  .tdx-feedback-modal {
    align-items: flex-start;
    padding: 10px;
  }

  .tdx-feedback-modal-content {
    margin-top: 20px;
  }
}
```

### Form Layout

```css
/* Custom form layout */
.tdx-feedback-form {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.tdx-feedback-field {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.tdx-feedback-label {
  font-weight: 500;
  color: #374151;
  font-size: 0.875rem;
}

.tdx-feedback-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid #e5e7eb;
}
```

## 🌈 Color Schemes

### Blue Theme

```css
:root {
  --tdx-primary: #3b82f6;
  --tdx-primary-hover: #2563eb;
  --tdx-primary-light: #dbeafe;
  --tdx-primary-border: #93c5fd;
}
```

### Green Theme

```css
:root {
  --tdx-primary: #10b981;
  --tdx-primary-hover: #059669;
  --tdx-primary-light: #d1fae5;
  --tdx-primary-border: #6ee7b7;
}
```

### Purple Theme

```css
:root {
  --tdx-primary: #8b5cf6;
  --tdx-primary-hover: #7c3aed;
  --tdx-primary-light: #ede9fe;
  --tdx-primary-border: #c4b5fd;
}
```

### Using CSS Variables

```css
.tdx-feedback-submit {
  background: var(--tdx-primary);
  color: white;
  border: 1px solid var(--tdx-primary);
}

.tdx-feedback-submit:hover:not(:disabled) {
  background: var(--tdx-primary-hover);
  border-color: var(--tdx-primary-hover);
}

.tdx-feedback-input:focus,
.tdx-feedback-textarea:focus {
  border-color: var(--tdx-primary);
  box-shadow: 0 0 0 3px var(--tdx-primary-light);
}
```

## 🔄 Next Steps

Now that you understand styling and theming:

1. **[Advanced Customization](Advanced-Customization.md)** - Extend functionality with JavaScript
2. **[Testing Guide](Testing)** - Test your custom styles
3. **[Performance Optimization](Performance-Optimization.md)** - Optimize CSS performance
4. **[Production Deployment](Production-Deployment.md)** - Deploy with custom styling

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting.md)
- Review [Configuration Guide](Configuration-Guide.md) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For advanced JavaScript customization, see the [Advanced Customization](Advanced-Customization.md) guide.*
