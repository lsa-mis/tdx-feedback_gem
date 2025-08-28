Complete guide to setting up the TDX Feedback Gem for development, including repository setup, test environment, contribution workflow, and code standards.

## 📋 Overview

This guide covers everything you need to set up a local development environment for contributing to the TDX Feedback Gem, from initial repository setup to running tests and submitting pull requests.

## 🚀 Repository Setup

### Prerequisites

Before setting up the development environment, ensure you have:

- **Ruby**: Version 3.1.0 or higher
- **Rails**: Version 6.1 or higher
- **Git**: Latest version
- **Database**: PostgreSQL 12+ or MySQL 8+
- **Node.js**: Version 16+ (for asset compilation)
- **Yarn**: Latest version

### Clone the Repository

```bash
# Clone the repository
git clone https://github.com/lsa-mis/tdx-feedback_gem.git
cd tdx_feedback_gem

# Add upstream remote (if you're working from a fork)
git remote add upstream https://github.com/lsa-mis/tdx-feedback_gem.git

# Verify remotes
git remote -v
```

### Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install JavaScript dependencies (if using Webpacker)
yarn install

# Or install with npm
npm install
```

### Database Setup

```bash
# Create test database
bundle exec rails db:create RAILS_ENV=test

# Run migrations
bundle exec rails db:migrate RAILS_ENV=test

# Seed test data (if available)
bundle exec rails db:seed RAILS_ENV=test
```

## 🧪 Test Environment

### Test Configuration

```ruby
# spec/rails_helper.rb
require 'spec_helper'
require 'rspec/rails'

RSpec.configure do |config|
  # Include factory methods
  config.include FactoryBot::Syntax::Methods

  # Database cleaner configuration
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  # Include test helpers
  config.include TdxFeedbackGem::TestHelpers
end

# spec/support/tdx_feedback_gem_test_helpers.rb
module TdxFeedbackGem::TestHelpers
  def disable_tdx_in_tests
    TdxFeedbackGem.configure do |config|
      config.enable_ticket_creation = false
    end
  end

  def enable_tdx_in_tests
    TdxFeedbackGem.configure do |config|
      config.enable_ticket_creation = true
    end
  end

  def mock_tdx_client
    client = instance_double(TdxFeedbackGem::Client)
    allow(TdxFeedbackGem::Client).to receive(:instance).and_return(client)
    client
  end
end
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/feedback_spec.rb

# Run tests with coverage
COVERAGE=true bundle exec rspec

# Run tests in parallel
bundle exec parallel_rspec spec/

# Run specific test
bundle exec rspec spec/models/feedback_spec.rb:25

# Run tests matching a pattern
bundle exec rspec --example "validates message presence"
```

### Test Data Setup

```ruby
# spec/factories/tdx_feedback_gem_feedbacks.rb
FactoryBot.define do
  factory :tdx_feedback_gem_feedback, class: 'TdxFeedbackGem::Feedback' do
    message { "Test feedback message" }
    context { "Test context information" }

    trait :with_user do
      user { create(:user) }
    end

    trait :with_tdx_ticket do
      tdx_ticket_id { "TDX-#{SecureRandom.hex(4).upcase}" }
    end

    trait :long_message do
      message { "a" * 1000 }
    end

    trait :empty_context do
      context { nil }
    end
  end
end

# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :admin do
      admin { true }
    end

    trait :with_feedback do
      after(:create) do |user|
        create_list(:tdx_feedback_gem_feedback, 3, user: user)
      end
    end
  end
end
```

### Integration Testing

```ruby
# spec/requests/feedback_flow_spec.rb
require 'rails_helper'

RSpec.describe 'Feedback Flow', type: :request do
  before do
    disable_tdx_in_tests
  end

  describe 'Complete feedback flow' do
    it 'allows users to submit feedback' do
      # Visit page with feedback trigger
      visit '/'

      # Click feedback button
      click_button 'Feedback'

      # Fill out form
      fill_in 'Message', with: 'Test feedback message'
      fill_in 'Context', with: 'Test context'

      # Submit form
      click_button 'Submit Feedback'

      # Verify success
      expect(page).to have_content('Feedback submitted successfully')

      # Verify feedback was created
      feedback = TdxFeedbackGem::Feedback.last
      expect(feedback.message).to eq('Test feedback message')
      expect(feedback.context).to eq('Test context')
    end
  end
end
```

## 🔧 Development Tools

### Code Quality Tools

```ruby
# .rubocop.yml
AllCops:
  TargetRubyVersion: 3.1
  NewCops: enable

Style/Documentation:
  Enabled: false

Style/StringLiterals:
  EnforcedStyle: single_quotes

Style/FrozenStringLiteralComment:
  Enabled: true

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'config/**/*'

Layout/LineLength:
  Max: 120
```

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Run specific cops
bundle exec rubocop --only Style/StringLiterals
```

### JavaScript Quality Tools

```javascript
// .eslintrc.js
module.exports = {
  env: {
    browser: true,
    es2021: true,
    node: true
  },
  extends: [
    'eslint:recommended',
    '@hotwired/stimulus/recommended'
  ],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module'
  },
  rules: {
    'indent': ['error', 2],
    'linebreak-style': ['error', 'unix'],
    'quotes': ['error', 'single'],
    'semi': ['error', 'always']
  }
};
```

```bash
# Run ESLint
npx eslint app/javascript/

# Auto-fix ESLint issues
npx eslint app/javascript/ --fix
```

### Pre-commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/sh

# Run RuboCop
bundle exec rubocop

# Run RSpec tests
bundle exec rspec --format progress

# Run ESLint
npx eslint app/javascript/

# Check for merge conflicts
git diff --cached --name-only | xargs grep -l "<<<<<<< HEAD" && exit 1

echo "Pre-commit checks passed!"
```

## 📝 Code Standards

### Ruby Code Style

```ruby
# Use snake_case for methods and variables
def enable_ticket_creation
  @options[:enable_ticket_creation]
end

# Use descriptive method names
def enable_ticket_creation=(value)
  @options[:enable_ticket_creation] = value
end

# Use guard clauses for early returns
def process_feedback(feedback)
  return false unless feedback.valid?
  return false unless feedback.user.present?

  # Process feedback logic
  true
end

# Use meaningful variable names
def create_tdx_ticket(feedback)
  client = TdxFeedbackGem::Client.instance
  response = client.create_ticket(feedback)

  if response.success?
    feedback.update!(tdx_ticket_id: response.ticket_id)
    true
  else
    false
  end
end
```

### JavaScript Code Style

```javascript
// Use camelCase for methods and variables
class TdxFeedbackController extends Controller {
  static targets = ["modal", "form"]

  // Use descriptive method names
  connect() {
    this.setupEventListeners()
  }

  setupEventListeners() {
    this.formTarget.addEventListener('submit', this.handleSubmit.bind(this))
  }

  // Use async/await for promises
  async handleSubmit(event) {
    event.preventDefault()

    try {
      const formData = this.prepareFormData()
      const response = await this.submitForm(formData)

      if (response.success) {
        this.showSuccess()
      } else {
        this.showErrors(response.errors)
      }
    } catch (error) {
      this.showError('An error occurred')
      console.error('Form submission error:', error)
    }
  }
}
```

### Documentation Standards

```ruby
# TdxFeedbackGem::Configuration
#
# Manages configuration for the TDX Feedback Gem.
# Supports configuration from multiple sources with priority resolution.
#
# @example
#   TdxFeedbackGem.configure do |config|
#     config.enable_ticket_creation = true
#     config.tdx_base_url = 'https://tdx.example.com'
#   end
#
# @attr [Boolean] enable_ticket_creation whether TDX ticket creation is enabled
# @attr [Integer] app_id the TDX application ID
# @attr [String] tdx_base_url the base URL for TDX API calls
class TdxFeedbackGem::Configuration
  # @return [Boolean] whether TDX ticket creation is enabled
  attr_accessor :enable_ticket_creation

  # @return [Integer] the TDX application ID
  attr_accessor :app_id

  # @return [String] the base URL for TDX API calls
  attr_accessor :tdx_base_url
end
```

```javascript
/**
 * TDX Feedback Controller
 *
 * Manages the feedback modal and form submission.
 * Handles opening/closing the modal and form interactions.
 *
 * @example
 * <button data-controller="tdx-feedback" data-action="click->tdx-feedback#openModal">
 *   Feedback
 * </button>
 */
export default class extends Controller {
  /**
   * Opens the feedback modal
   * @param {Event} event - The click event
   */
  openModal(event) {
    event.preventDefault()
    this.modalTarget.classList.add('show')
  }

  /**
   * Closes the feedback modal
   */
  closeModal() {
    this.modalTarget.classList.remove('show')
  }
}
```

## 🔄 Contribution Workflow

### Branch Naming Convention

```bash
# Feature branches
git checkout -b feature/add-custom-validation

# Bug fix branches
git checkout -b fix/modal-not-closing

# Documentation branches
git checkout -b docs/update-api-documentation

# Refactor branches
git checkout -b refactor/improve-error-handling
```

### Commit Message Convention

```bash
# Use conventional commit format
feat: add custom validation for feedback messages

fix: resolve modal not closing on escape key

docs: update API documentation with examples

refactor: improve error handling in TDX client

test: add integration tests for feedback flow

style: fix RuboCop violations in configuration

chore: update dependencies to latest versions
```

### Pull Request Process

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Write code following style guidelines
   - Add tests for new functionality
   - Update documentation as needed

3. **Run Tests**
   ```bash
   bundle exec rspec
   bundle exec rubocop
   npx eslint app/javascript/
   ```

4. **Commit Changes**
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. **Push Branch**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Use the PR template
   - Describe changes clearly
   - Link related issues
   - Request reviews from maintainers

### Pull Request Template

```markdown
## Description
Brief description of the changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Added tests for new functionality
- [ ] All tests pass locally
- [ ] Updated existing tests as needed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes introduced

## Related Issues
Closes #123
```

## 🐛 Debugging

### Debug Configuration

```ruby
# config/environments/development.rb
Rails.application.configure do
  # Enable debugging
  config.log_level = :debug

  # Enable detailed logging for TDX Feedback Gem
  config.tdx_feedback_gem = {
    debug: true,
    log_level: :debug
  }
end
```

### Debug Helpers

```ruby
# lib/tdx_feedback_gem/debug_helper.rb
module TdxFeedbackGem::DebugHelper
  def debug_feedback_creation(feedback)
    Rails.logger.debug "Creating feedback: #{feedback.attributes}"
    Rails.logger.debug "User: #{feedback.user&.email}"
    Rails.logger.debug "TDX enabled: #{TdxFeedbackGem.configuration.enable_ticket_creation}"
  end

  def debug_tdx_api_call(endpoint, payload)
    Rails.logger.debug "TDX API Call: #{endpoint}"
    Rails.logger.debug "Payload: #{payload}"
  end
end
```

### Console Debugging

```ruby
# Start Rails console
bundle exec rails console

# Test configuration
TdxFeedbackGem.configuration.enable_ticket_creation
TdxFeedbackGem.configuration.tdx_base_url

# Test client
client = TdxFeedbackGem::Client.instance
client.test_connection

# Test feedback creation
feedback = TdxFeedbackGem::Feedback.new(message: "Test message")
feedback.valid?
feedback.errors.full_messages
```

## 📊 Performance Monitoring

### Development Performance Tools

```ruby
# Gemfile
group :development do
  gem 'bullet'
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'stackprof'
end
```

```ruby
# config/environments/development.rb
Rails.application.configure do
  # Enable Bullet for N+1 query detection
  config.after_initialize do
    Bullet.enable = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
  end

  # Enable rack-mini-profiler
  config.rack_mini_profiler = true
end
```

### Performance Testing

```ruby
# spec/performance/feedback_performance_spec.rb
require 'rails_helper'

RSpec.describe 'Feedback Performance', type: :performance do
  it 'handles multiple feedback submissions efficiently' do
    expect {
      100.times do
        post '/tdx_feedback_gem/feedbacks', params: {
          feedback: { message: "Performance test #{rand(1000)}" }
        }
      end
    }.to change(TdxFeedbackGem::Feedback, :count).by(100)
  end

  it 'modal loads within performance budget' do
    start_time = Time.current

    get '/tdx_feedback_gem/feedbacks/new'

    duration = ((Time.current - start_time) * 1000).round
    expect(duration).to be < 100 # Should load in under 100ms
  end
end
```

## 🔄 Continuous Integration

### GitHub Actions Configuration

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3

    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.1
        bundler-cache: true

    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y postgresql-client

    - name: Set up database
      run: |
        bundle exec rails db:create RAILS_ENV=test
        bundle exec rails db:migrate RAILS_ENV=test
        bundle exec rails db:test:prepare

    - name: Run tests
      run: bundle exec rspec

    - name: Run RuboCop
      run: bundle exec rubocop

    - name: Run ESLint
      run: npx eslint app/javascript/
```

## 🔄 Next Steps

Now that you have your development environment set up:

1. **[Contributing Guidelines](Contributing)** - Learn about contribution standards
2. **[Testing Guide](Testing)** - Write and run tests
3. **[Code Standards](Contributing)** - Follow coding conventions
4. **[Pull Request Process](Contributing)** - Submit your contributions

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Contributing Guidelines](Contributing) for contribution details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub
- Join the development discussion

---

*For more details about contributing, see the [Contributing Guidelines](Contributing) guide.*
