# Testing Guide

Complete guide to testing the TDX Feedback Gem integration in your Rails application.

## 🧪 Test Setup

### Prerequisites

- **RSpec** - Testing framework
- **Database** - Test database configured
- **Test Environment** - Rails test environment setup

### Installation

The gem includes a comprehensive test suite. To set up testing:

```bash
# Install dependencies
bundle install

# Run the install generator (if not already done)
rails generate tdx_feedback_gem:install

# Set up test database
rails db:test:prepare
```

### Test Configuration

#### RSpec Configuration

```ruby
# spec/spec_helper.rb
require 'rails_helper'

# Configure TDX Feedback Gem for testing
TdxFeedbackGem.configure do |config|
  config.enable_ticket_creation = true
  config.tdx_base_url = 'https://test-api.example.com'
  config.oauth_token_url = 'https://test-api.example.com/oauth/token'
  config.client_id = 'test_client_id'
  config.client_secret = 'test_client_secret'
  config.app_id = 123
  config.type_id = 456
  config.status_id = 112
  config.source_id = 131
  config.service_id = 415
  config.responsible_group_id = 161
end
```

#### Test Environment Configuration

```ruby
# config/environments/test.rb
Rails.application.configure do
  # ... other test configuration ...

  # TDX Feedback Gem test configuration
  config.tdx_feedback_gem = {
    enable_ticket_creation: false,  # Disable in tests by default
    log_level: :debug
  }
end
```

#### Factory Configuration

```ruby
# spec/factories/tdx_feedback_gem_feedbacks.rb
FactoryBot.define do
  factory :tdx_feedback_gem_feedback, class: 'TdxFeedbackGem::Feedback' do
    message { "Test feedback message" }
    context { "Test context information" }
  end
end
```

## 🚀 Running Tests

### Basic Test Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/controllers/tdx_feedback_gem/feedbacks_controller_spec.rb
bundle exec rspec spec/models/feedback_spec.rb
bundle exec rspec spec/requests/feedback_flow_spec.rb

# Run tests with coverage report
COVERAGE=true bundle exec rspec

# Run tests in parallel (if parallel_tests gem is installed)
bundle exec parallel_rspec spec/
```

### Test Database Setup

```bash
# Create test database
rails db:create RAILS_ENV=test

# Run migrations
rails db:migrate RAILS_ENV=test

# Prepare test database
rails db:test:prepare

# Reset test database
rails db:test:reset
```

### Continuous Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

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
      env:
        RAILS_ENV: test
        DATABASE_URL: postgres://postgres:postgres@localhost:5432/tdx_feedback_gem_test
```

## 📊 Test Coverage

### What's Tested

The test suite covers all major functionality:

#### Configuration Management
- Configuration options and resolution logic
- Environment variable fallbacks
- Rails credentials integration
- Runtime configuration toggles

#### TDX Client
- API communication
- OAuth token management
- Error handling and retries
- Rate limiting

#### Ticket Creation
- TDX ticket creation flow
- Error scenarios and handling
- Result processing
- Validation

#### Controller Actions
- Form submission
- Validation
- Authentication
- Response handling

#### Model Validation
- Feedback model constraints
- Field validations
- Database interactions

#### Helper Methods
- All view helper functionality
- Parameter handling
- HTML generation

#### Integration Flow
- Complete feedback submission workflow
- Modal interactions
- Form submission
- Success/error handling

### Coverage Report

```bash
# Generate coverage report
COVERAGE=true bundle exec rspec

# View coverage in browser
open coverage/index.html
```

## 🧩 Test Types

### Unit Tests

#### Model Tests

```ruby
# spec/models/feedback_spec.rb
require 'rails_helper'

RSpec.describe TdxFeedbackGem::Feedback, type: :model do
  describe 'validations' do
    it 'is valid with a message' do
      feedback = build(:tdx_feedback_gem_feedback)
      expect(feedback).to be_valid
    end

    it 'requires a message' do
      feedback = build(:tdx_feedback_gem_feedback, message: nil)
      expect(feedback).not_to be_valid
      expect(feedback.errors[:message]).to include("can't be blank")
    end

    it 'limits context to 10000 characters' do
      feedback = build(:tdx_feedback_gem_feedback, context: 'a' * 10001)
      expect(feedback).not_to be_valid
      expect(feedback.errors[:context]).to include('is too long (maximum is 10000 characters)')
    end
  end

  describe 'associations' do
    it 'can be associated with a user' do
      user = create(:user)
      feedback = create(:tdx_feedback_gem_feedback, user: user)
      expect(feedback.user).to eq(user)
    end
  end
end
```

#### Configuration Tests

```ruby
# spec/configuration_spec.rb
require 'rails_helper'

RSpec.describe TdxFeedbackGem::Configuration do
  let(:config) { TdxFeedbackGem::Configuration.new }

  describe 'default values' do
    it 'has sensible defaults' do
      expect(config.require_authentication).to be false
      expect(config.enable_ticket_creation).to be false
      expect(config.title_prefix).to eq('[Feedback]')
    end
  end

  describe 'configuration block' do
    it 'allows configuration via block' do
      TdxFeedbackGem.configure do |config|
        config.require_authentication = true
        config.enable_ticket_creation = true
      end

      expect(TdxFeedbackGem.configuration.require_authentication).to be true
      expect(TdxFeedbackGem.configuration.enable_ticket_creation).to be true
    end
  end
end
```

### Controller Tests

```ruby
# spec/controllers/tdx_feedback_gem/feedbacks_controller_spec.rb
require 'rails_helper'

RSpec.describe TdxFeedbackGem::FeedbacksController, type: :controller do
  describe 'GET #new' do
    it 'returns modal HTML' do
      get :new, format: :json
      expect(response).to be_successful

      json = JSON.parse(response.body)
      expect(json['html']).to include('tdx-feedback-modal')
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a feedback record' do
        expect {
          post :create, params: {
            feedback: { message: 'Test feedback' }
          }, format: :json
        }.to change(TdxFeedbackGem::Feedback, :count).by(1)

        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['success']).to be true
      end
    end

    context 'with invalid parameters' do
      it 'returns errors' do
        post :create, params: {
          feedback: { message: '' }
        }, format: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['success']).to be false
        expect(json['errors']).to include("Message can't be blank")
      end
    end
  end
end
```

### Request Tests

```ruby
# spec/requests/feedback_flow_spec.rb
require 'rails_helper'

RSpec.describe 'Feedback Flow', type: :request do
  describe 'feedback submission flow' do
    it 'allows users to submit feedback' do
      # Get modal HTML
      get '/tdx_feedback_gem/feedbacks/new', headers: { 'Accept' => 'application/json' }
      expect(response).to be_successful

      # Submit feedback
      post '/tdx_feedback_gem/feedbacks', params: {
        feedback: { message: 'Test feedback message' }
      }, headers: { 'Accept' => 'application/json' }

      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json['success']).to be true

      # Verify feedback was created
      feedback = TdxFeedbackGem::Feedback.last
      expect(feedback.message).to eq('Test feedback message')
    end
  end

  describe 'authentication' do
    context 'when authentication is required' do
      before do
        TdxFeedbackGem.configure { |config| config.require_authentication = true }
      end

      it 'requires authentication for feedback submission' do
        post '/tdx_feedback_gem/feedbacks', params: {
          feedback: { message: 'Test feedback' }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
```

### Integration Tests

```ruby
# spec/integration/tdx_integration_spec.rb
require 'rails_helper'

RSpec.describe 'TDX Integration', type: :integration do
  let(:tdx_client) { instance_double(TdxFeedbackGem::Client) }

  before do
    allow(TdxFeedbackGem::Client).to receive(:new).and_return(tdx_client)
  end

  describe 'ticket creation' do
    context 'when TDX is enabled' do
      before do
        TdxFeedbackGem.configure { |config| config.enable_ticket_creation = true }
      end

      it 'creates TDX tickets' do
        expect(tdx_client).to receive(:create_ticket).and_return(
          double(success?: true, ticket_id: 'TDX-123')
        )

        post '/tdx_feedback_gem/feedbacks', params: {
          feedback: { message: 'Test feedback' }
        }, format: :json

        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json['ticket_id']).to eq('TDX-123')
      end
    end

    context 'when TDX is disabled' do
      before do
        TdxFeedbackGem.configure { |config| config.enable_ticket_creation = false }
      end

      it 'does not create TDX tickets' do
        expect(tdx_client).not_to receive(:create_ticket)

        post '/tdx_feedback_gem/feedbacks', params: {
          feedback: { message: 'Test feedback' }
        }, format: :json

        expect(response).to be_successful
        json = JSON.parse(response.body)
        expect(json).not_to have_key('ticket_id')
      end
    end
  end
end
```

## 🔧 Test Helpers

### Custom Matchers

```ruby
# spec/support/matchers/tdx_matchers.rb
RSpec::Matchers.define :have_tdx_ticket do
  match do |feedback|
    feedback.tdx_ticket_id.present?
  end

  failure_message do |feedback|
    "expected feedback to have TDX ticket, but got: #{feedback.tdx_ticket_id.inspect}"
  end
end

RSpec::Matchers.define :be_tdx_enabled do
  match do
    TdxFeedbackGem.configuration.enable_ticket_creation?
  end

  failure_message do
    "expected TDX to be enabled, but it was disabled"
  end
end
```

### Test Utilities

```ruby
# spec/support/tdx_test_helpers.rb
module TdxTestHelpers
  def enable_tdx_in_tests
    TdxFeedbackGem.configure do |config|
      config.enable_ticket_creation = true
      config.tdx_base_url = 'https://test-api.example.com'
      config.client_id = 'test_client_id'
      config.client_secret = 'test_client_secret'
    end
  end

  def disable_tdx_in_tests
    TdxFeedbackGem.configure do |config|
      config.enable_ticket_creation = false
    end
  end

  def mock_tdx_client
    client = instance_double(TdxFeedbackGem::Client)
    allow(TdxFeedbackGem::Client).to receive(:new).and_return(client)
    client
  end
end

RSpec.configure do |config|
  config.include TdxTestHelpers
end
```

### Database Cleanup

```ruby
# spec/support/database_cleaner.rb
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
```

## 🚨 Common Test Issues

### Issue: Database Connection

**Symptoms:**
- Tests fail with database connection errors
- "database does not exist" errors

**Solutions:**
```bash
# Create test database
rails db:create RAILS_ENV=test

# Run migrations
rails db:migrate RAILS_ENV=test

# Prepare test database
rails db:test:prepare
```

### Issue: Configuration Conflicts

**Symptoms:**
- Tests behave differently than expected
- Configuration values don't match

**Solutions:**
```ruby
# Reset configuration in each test
before(:each) do
  TdxFeedbackGem.configure do |config|
    config.enable_ticket_creation = false
    config.require_authentication = false
  end
end
```

### Issue: Asset Loading

**Symptoms:**
- JavaScript errors in tests
- CSS not loading

**Solutions:**
```ruby
# Ensure assets are precompiled for tests
config.before(:suite) do
  Rails.application.load_tasks
  Rake::Task['assets:precompile'].invoke
end
```

## 📈 Performance Testing

### Load Testing

```ruby
# spec/performance/feedback_performance_spec.rb
require 'rails_helper'

RSpec.describe 'Feedback Performance', type: :performance do
  it 'handles multiple concurrent submissions' do
    expect {
      threads = 10.times.map do
        Thread.new do
          post '/tdx_feedback_gem/feedbacks', params: {
            feedback: { message: "Performance test #{rand(1000)}" }
          }
        end
      end

      threads.each(&:join)
    }.to change(TdxFeedbackGem::Feedback, :count).by(10)
  end
end
```

### Memory Testing

```ruby
# spec/performance/memory_spec.rb
require 'rails_helper'

RSpec.describe 'Memory Usage', type: :performance do
  it 'does not leak memory during feedback submission' do
    initial_memory = GetProcessMem.new.mb

    100.times do
      post '/tdx_feedback_gem/feedbacks', params: {
        feedback: { message: "Memory test #{rand(1000)}" }
      }
    end

    final_memory = GetProcessMem.new.mb
    memory_increase = final_memory - initial_memory

    expect(memory_increase).to be < 10 # Less than 10MB increase
  end
end
```

## 🔄 Next Steps

Now that you understand testing:

1. **[Performance Optimization](Performance-Optimization)** - Optimize your application
2. **[Production Deployment](Production-Deployment)** - Deploy with confidence
3. **[Advanced Customization](Advanced-Customization)** - Extend functionality
4. **[Troubleshooting Guide](Troubleshooting)** - Solve common issues

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Configuration Guide](Configuration-Guide) for setup details
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub

---

*For more advanced testing patterns, see the [Advanced Customization](Advanced-Customization) guide.*
