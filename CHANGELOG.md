# Changelog

All notable changes to this project will be documented here.
This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.1] - 2025-09-08

### Fixed

- Improved resilience in `TdxFeedbackController#close`:
  - Controller now attempts to rebind modal, overlay, and form elements if references are lost.
  - Prevents situations where the modal fails to close if DOM elements are re-rendered or replaced.

## [0.1.0] - 2025-09-01

### Added

- Initial release of `tdx_feedback_gem`.
