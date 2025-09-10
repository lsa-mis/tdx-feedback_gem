# Changelog

All notable changes to this project will be documented here.
This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added (since 0.1.1)

- Importmap auto-pin integration spec (`spec/integration/importmap_auto_pin_spec.rb`) to verify Stimulus controller is pinned exactly once and initializer is idempotent.
- `auto_pin_importmap` and `runtime_scss_copy` configuration flags with credential → ENV → default precedence.
- `tdx_feedback_gem:update_assets` generator for refreshing SCSS partial and Stimulus controller copies in host apps.

### Changed (since 0.1.1)

- `lib/tdx_feedback_gem/engine.rb`: Refactored to:
  - Add auto importmap pin initializer (`tdx_feedback_gem.auto_pin_controller`).
  - Gate runtime SCSS copy behind `runtime_scss_copy` (default enabled only in dev/test-like envs).
  - Remove unconditional runtime asset mutation for production safety / immutable builds.
- `lib/tdx_feedback_gem/configuration.rb`: Centralized resolution logic for new flags (`auto_pin_importmap`, `runtime_scss_copy`).
- `lib/generators/tdx_feedback_gem/update_assets/update_assets_generator.rb`: New generator introduced (ensures asset refresh without runtime mutation).
- `Gemfile`: Added `importmap-rails` to development/test dependencies to support and test auto-pin behavior.

### Documentation (since 0.1.1)

- Updated README and Testing Guide with auto-pin behavior, configuration flags, and update-assets generator usage.

### Internal (since 0.1.1)

- Adjusted integration test scaffolding (dummy app assets, Gemfile) to stabilize test suite under new engine behavior.

## [0.1.1] - 2025-09-08

### Fixed

- Improved resilience in `TdxFeedbackController#close`:
  - Controller now attempts to rebind modal, overlay, and form elements if references are lost.
  - Prevents situations where the modal fails to close if DOM elements are re-rendered or replaced.

## [0.1.0] - 2025-09-01

### Added

- Initial release of `tdx_feedback_gem`.
