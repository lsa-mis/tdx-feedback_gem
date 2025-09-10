# Changelog

All notable changes to this project will be documented here.
This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.1.3] - 2025-09-10

### Fixed
- Prevent FrozenError by guarding importmap path registration (only add engine JS path when importmap.json exists; always allowed in test env).

### Added
- Configuration validation (`validate_configuration!`) emitting non-fatal warnings (misconfigured ticket IDs, unsafe production flags, missing Importmap).
- Safer install generator: automatically mounts engine, optional importmap pin_all_from snippet, clearer instructions.
- `app/javascript/importmap.json` shipped for importmap detection.

### Changed
- Importmap auto-pin logic hardened (idempotent forced pin; resilient when pinned? semantics vary in host or test stubs).
- Helper inclusion and asset logic wrapped with error handling & debug logging via Rails.logger only (temporary puts removed).
- Default behavior: runtime SCSS copy & auto-pin remain configurable while avoiding unintended production mutations.

### Internal
- Added late fallback initializer for auto-pin in atypical initialization orders (tests / custom boot flows).
- Removed temporary debug STDOUT instrumentation.

## [0.1.2] - 2025-09-09

### Added

- Importmap auto-pin integration spec (`spec/integration/importmap_auto_pin_spec.rb`) to verify Stimulus controller is pinned exactly once and initializer is idempotent.
- `auto_pin_importmap` and `runtime_scss_copy` configuration flags with credential → ENV → default precedence.
- `tdx_feedback_gem:update_assets` generator for refreshing SCSS partial and Stimulus controller copies in host apps.

### Changed

- `lib/tdx_feedback_gem/engine.rb`: Refactored to:
  - Add auto importmap pin initializer (`tdx_feedback_gem.auto_pin_controller`).
  - Gate runtime SCSS copy behind `runtime_scss_copy` (default enabled only in dev/test-like envs).
  - Remove unconditional runtime asset mutation for production safety / immutable builds.
- `lib/tdx_feedback_gem/configuration.rb`: Centralized resolution logic for new flags (`auto_pin_importmap`, `runtime_scss_copy`).
- `lib/generators/tdx_feedback_gem/update_assets/update_assets_generator.rb`: New generator introduced (ensures asset refresh without runtime mutation).
- `Gemfile`: Added `importmap-rails` to development/test dependencies to support and test auto-pin behavior.

### Documentation

- Updated README and Testing Guide with auto-pin behavior, configuration flags, and update-assets generator usage.

### Internal

- Adjusted integration test scaffolding (dummy app assets, Gemfile) to stabilize test suite under new engine behavior.

## [0.1.1] - 2025-09-08

### Fixed

- Improved resilience in `TdxFeedbackController#close`:
  - Controller now attempts to rebind modal, overlay, and form elements if references are lost.
  - Prevents situations where the modal fails to close if DOM elements are re-rendered or replaced.

## [0.1.0] - 2025-09-01

### Added

- Initial release of `tdx_feedback_gem`.
