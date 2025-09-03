# Testing Guide

Complete guide to testing the TDX Feedback Gem, including test setup, RSpec configuration, test examples, and testing best practices.

## 📋 Overview

This guide covers everything you need to know about testing the TDX Feedback Gem, from initial test setup to writing comprehensive tests for all components including models, controllers, views, and JavaScript functionality.

## 🧪 Test Environment Setup

### Prerequisites

Before setting up tests, ensure you have:

- **Ruby**: Version 3.1.0 or higher
- **Rails**: Version 6.1 or higher
- **RSpec**: Latest version
- **Database**: PostgreSQL 12+ or MySQL 8+ for testing
- **Node.js**: Version 16+ (for JavaScript tests)

### Initial Setup

```bash
# Install RSpec and testing dependencies
bundle add rspec-rails --group=development,test
bundle add factory_bot_rails --group=development,test
bundle add database_cleaner-active_record --group=test
bundle add shoulda-matchers --group=test
bundle add capybara --group=test
bundle add selenium-webdriver --group=test
bundle add webdrivers --group=test

# Generate RSpec configuration
bundle exec rails generate rspec:install

# Install JavaScript testing dependencies
yarn add --dev jest @testing-library/jest-dom @testing-library/dom
```

### Test Configuration

```ruby
# spec/rails_helper.rb
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'factory_bot_rails'

# Load support files
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Include factory methods
  config.include FactoryBot::Syntax::Methods

  # Include Capybara methods
  config.include Capybara::DSL

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

  # Use transactional fixtures
  config.use_transactional_fixtures = true

  # Filter tests
  config.filter_run_when_matching :focus
  config.run_all_when_everything_filtered = true

  # Randomize test order
  config.order = :random
  Kernel.srand config.seed
end

# Capybara configuration
Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless
Capybara.server = :puma, { Silent: true }

# Shoulda Matchers configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

### Test Helpers

```ruby
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

  def create_mock_tdx_response(success: true, ticket_id: nil, error: nil)
    double(
      success?: success,
      ticket_id: ticket_id,
      error: error
    )
  end

  def sign_in_user(user = nil)
    user ||= create(:user)
    allow(controller).to receive(:current_user).and_return(user)
    user
  end

  def sign_out_user
    allow(controller).to receive(:current_user).and_return(nil)
  end
end
```

## 🏭 Factory Definitions

### Feedback Factory

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

    trait :bug_report do
      message { "I found a bug in the system" }
      context { "Steps to reproduce: 1. Go to page 2. Click button 3. Error occurs" }
    end

    trait :feature_request do
      message { "I would like to request a new feature" }
      context { "This would improve user experience by..." }
    end

    trait :general_feedback do
      message { "General feedback about the application" }
      context { "Overall thoughts and suggestions" }
    end
  end
end
```

### User Factory

```ruby
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

    trait :with_many_feedback do
      after(:create) do |user|
        create_list(:tdx_feedback_gem_feedback, 10, user: user)
      end
    end
  end
end
```

## 🧪 Model Testing

### Feedback Model Tests

```ruby
# spec/models/tdx_feedback_gem/feedback_spec.rb
require 'rails_helper'

RSpec.describe TdxFeedbackGem::Feedback, type: :model do
  describe 'validations' do
    subject { build(:tdx_feedback_gem_feedback) }

    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_length_of(:message).is_at_most(10000) }
    it { is_expected.to validate_length_of(:context).is_at_most(10000) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'scopes' do
    let!(:recent_feedback) { create(:tdx_feedback_gem_feedback, created_at: 1.hour.ago) }
    let!(:old_feedback) { create(:tdx_feedback_gem_feedback, created_at: 2.days.ago) }

    describe '.recent' do
      it 'returns feedback ordered by creation date' do
        expect(described_class.recent).to eq([recent_feedback, old_feedback])
      end
    end

    describe '.with_tdx_tickets' do
      let!(:feedback_with_ticket) { create(:tdx_feedback_gem_feedback, :with_tdx_ticket) }

      it 'returns only feedback with TDX tickets' do
        expect(described_class.with_tdx_tickets).to include(feedback_with_ticket)
        expect(described_class.with_tdx_tickets).not_to include(recent_feedback)
      end
    end

    describe '.without_tdx_tickets' do
      let!(:feedback_with_ticket) { create(:tdx_feedback_gem_feedback, :with_tdx_ticket) }

      it 'returns only feedback without TDX tickets' do
        expect(described_class.without_tdx_tickets).to include(recent_feedback)
        expect(described_class.without_tdx_tickets).not_to include(feedback_with_ticket)
      end
    end
  end

  describe 'instance methods' do
    describe '#has_tdx_ticket?' do
      it 'returns true when tdx_ticket_id is present' do
        feedback = build(:tdx_feedback_gem_feedback, :with_tdx_ticket)
        expect(feedback.has_tdx_ticket?).to be true
      end

      it 'returns false when tdx_ticket_id is nil' do
        feedback = build(:tdx_feedback_gem_feedback)
        expect(feedback.has_tdx_ticket?).to be false
      end
    end

    describe '#tdx_ticket_created?' do
      it 'returns true when tdx_ticket_id is present' do
        feedback = build(:tdx_feedback_gem_feedback, :with_tdx_ticket)
        expect(feedback.tdx_ticket_created?).to be true
      end

      it 'returns false when tdx_ticket_id is nil' do
        feedback = build(:tdx_feedback_gem_feedback)
        expect(feedback.tdx_ticket_created?).to be false
      end
    end
  end

  describe 'edge cases' do
    it 'handles very long messages' do
      long_message = "a" * 10000
      feedback = build(:tdx_feedback_gem_feedback, message: long_message)
      expect(feedback).to be_valid
    end

    it 'handles very long context' do
      long_context = "a" * 10000
      feedback = build(:tdx_feedback_gem_feedback, context: long_context)
      expect(feedback).to be_valid
    end

    it 'handles empty context' do
      feedback = build(:tdx_feedback_gem_feedback, context: '')
      expect(feedback).to be_valid
    end

    it 'handles nil context' do
      feedback = build(:tdx_feedback_gem_feedback, context: nil)
      expect(feedback).to be_valid
    end
  end
end
```

## 🎮 Controller Testing

### Feedbacks Controller Tests

```ruby
# spec/controllers/tdx_feedback_gem/feedbacks_controller_spec.rb
require 'rails_helper'

RSpec.describe TdxFeedbackGem::FeedbacksController, type: :controller do
  before do
    disable_tdx_in_tests
  end

  describe 'GET #new' do
    context 'when user is authenticated' do
      let(:user) { create(:user) }

      before { sign_in_user(user) }

      it 'returns success' do
        get :new
        expect(response).to be_successful
      end

      it 'renders new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'assigns a new feedback' do
        get :new
        expect(assigns(:feedback)).to be_a_new(TdxFeedbackGem::Feedback)
      end
    end

    context 'when user is not authenticated' do
      before { sign_out_user }

      it 'returns success (allows anonymous feedback)' do
        get :new
        expect(response).to be_successful
      end
    end

    context 'with AJAX request' do
      it 'returns JSON response' do
        get :new, xhr: true
        expect(response.content_type).to include('application/json')
      end

      it 'includes modal HTML in response' do
        get :new, xhr: true
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['html']).to be_present
      end
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        feedback: {
          message: 'Test feedback message',
          context: 'Test context'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new feedback' do
        expect {
          post :create, params: valid_params
        }.to change(TdxFeedbackGem::Feedback, :count).by(1)
      end

      it 'returns success status' do
        post :create, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns JSON response' do
        post :create, params: valid_params
        expect(response.content_type).to include('application/json')
      end

      it 'includes feedback data in response' do
        post :create, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['feedback']['message']).to eq('Test feedback message')
      end

      context 'when user is authenticated' do
        let(:user) { create(:user) }

        before { sign_in_user(user) }

        it 'associates feedback with user' do
          post :create, params: valid_params
          expect(TdxFeedbackGem::Feedback.last.user).to eq(user)
        end
      end

      context 'when user is not authenticated' do
        before { sign_out_user }

        it 'creates feedback without user association' do
          post :create, params: valid_params
          expect(TdxFeedbackGem::Feedback.last.user).to be_nil
        end
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          feedback: {
            message: '',
            context: 'Test context'
          }
        }
      end

      it 'does not create a feedback' do
        expect {
          post :create, params: invalid_params
        }.not_to change(TdxFeedbackGem::Feedback, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        post :create, params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to include('message')
      end
    end

    context 'with AJAX request' do
      it 'returns JSON response' do
        post :create, params: valid_params, xhr: true
        expect(response.content_type).to include('application/json')
      end
    end
  end

  describe 'TDX ticket creation' do
    before do
      enable_tdx_in_tests
    end

    let(:user) { create(:user) }
    let(:valid_params) do
      {
        feedback: {
          message: 'Test feedback message',
          context: 'Test context'
        }
      }
    end

    context 'when TDX ticket creation is enabled' do
      it 'attempts to create TDX ticket' do
        mock_client = mock_tdx_client
        mock_response = create_mock_tdx_response(success: true, ticket_id: 'TDX-123')

        allow(mock_client).to receive(:create_ticket).and_return(mock_response)

        post :create, params: valid_params

        expect(mock_client).to have_received(:create_ticket)
      end

      it 'updates feedback with TDX ticket ID on success' do
        mock_client = mock_tdx_client
        mock_response = create_mock_tdx_response(success: true, ticket_id: 'TDX-123')

        allow(mock_client).to receive(:create_ticket).and_return(mock_response)

        post :create, params: valid_params

        feedback = TdxFeedbackGem::Feedback.last
        expect(feedback.tdx_ticket_id).to eq('TDX-123')
      end

      it 'handles TDX ticket creation failure gracefully' do
        mock_client = mock_tdx_client
        mock_response = create_mock_tdx_response(success: false, error: 'API Error')

        allow(mock_client).to receive(:create_ticket).and_return(mock_response)

        expect {
          post :create, params: valid_params
        }.not_to raise_error

        feedback = TdxFeedbackGem::Feedback.last
        expect(feedback.tdx_ticket_id).to be_nil
      end
    end
  end
end
```

## 🌐 Request/Integration Testing

### Feedback Flow Tests

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

    it 'handles validation errors gracefully' do
      visit '/'
      click_button 'Feedback'

      # Try to submit without message
      click_button 'Submit Feedback'

      # Verify error message
      expect(page).to have_content("Message can't be blank")

      # Verify no feedback was created
      expect(TdxFeedbackGem::Feedback.count).to eq(0)
    end

    it 'allows anonymous feedback submission' do
      visit '/'
      click_button 'Feedback'

      fill_in 'Message', with: 'Anonymous feedback'
      click_button 'Submit Feedback'

      expect(page).to have_content('Feedback submitted successfully')

      feedback = TdxFeedbackGem::Feedback.last
      expect(feedback.user).to be_nil
    end
  end

  describe 'AJAX feedback submission' do
    it 'submits feedback via AJAX' do
      visit '/'

      # Use JavaScript to submit form
      page.execute_script(<<~JS)
        const form = document.querySelector('.tdx-feedback-form');
        const messageInput = form.querySelector('textarea[name="feedback[message]"]');
        const contextInput = form.querySelector('textarea[name="feedback[context]"]');

        messageInput.value = 'AJAX feedback message';
        contextInput.value = 'AJAX context';

        const submitEvent = new Event('submit', { bubbles: true });
        form.dispatchEvent(submitEvent);
      JS

      # Wait for response
      expect(page).to have_content('Feedback submitted successfully')

      # Verify feedback was created
      feedback = TdxFeedbackGem::Feedback.last
      expect(feedback.message).to eq('AJAX feedback message')
    end
  end

  describe 'Modal behavior' do
    it 'opens and closes modal correctly' do
      visit '/'

      # Modal should not be visible initially
      expect(page).not_to have_selector('.tdx-feedback-modal.show')

      # Click feedback button to open modal
      click_button 'Feedback'
      expect(page).to have_selector('.tdx-feedback-modal.show')

      # Click close button to close modal
      click_button 'Close'
      expect(page).not_to have_selector('.tdx-feedback-modal.show')
    end

    it 'closes modal when clicking overlay' do
      visit '/'
      click_button 'Feedback'

      # Click on overlay to close modal
      find('.tdx-feedback-modal-overlay').click
      expect(page).not_to have_selector('.tdx-feedback-modal.show')
    end

    it 'closes modal when pressing Escape key' do
      visit '/'
      click_button 'Feedback'

      # Press Escape key
      page.send_keys(:escape)
      expect(page).not_to have_selector('.tdx-feedback-modal.show')
    end
  end
end
```

## 🧪 JavaScript Testing

### Stimulus Controller Tests

```javascript
// spec/javascript/controllers/tdx_feedback_controller.test.js
import { Application } from "@hotwired/stimulus"
import TdxFeedbackController from "../../controllers/tdx_feedback_controller"

describe("TdxFeedbackController", () => {
  let application
  let controller
  let element

  beforeEach(() => {
    application = Application.start()
    application.register("tdx-feedback", TdxFeedbackController)

    element = document.createElement("div")
    element.setAttribute("data-controller", "tdx-feedback")
    element.innerHTML = `
      <div data-tdx-feedback-target="modal" class="tdx-feedback-modal">
        <form data-tdx-feedback-target="form" class="tdx-feedback-form">
          <textarea data-tdx-feedback-target="message" name="feedback[message]"></textarea>
          <textarea data-tdx-feedback-target="context" name="feedback[context]"></textarea>
          <button data-tdx-feedback-target="submitButton" type="submit">Submit</button>
        </form>
        <button data-tdx-feedback-target="closeButton">Close</button>
      </div>
    `

    document.body.appendChild(element)
    controller = application.getControllerForElementAndIdentifier(element, "tdx-feedback")
  })

  afterEach(() => {
    document.body.removeChild(element)
    application.stop()
  })

  describe("openModal", () => {
    it("opens the modal", () => {
      controller.openModal()
      expect(controller.modalTarget.classList.contains("show")).toBe(true)
    })

    it("focuses the message input", () => {
      controller.openModal()
      expect(document.activeElement).toBe(controller.messageTarget)
    })

    it("adds modal-open class to body", () => {
      controller.openModal()
      expect(document.body.classList.contains("modal-open")).toBe(true)
    })
  })

  describe("closeModal", () => {
    beforeEach(() => {
      controller.openModal()
    })

    it("closes the modal", () => {
      controller.closeModal()
      expect(controller.modalTarget.classList.contains("show")).toBe(false)
    })

    it("removes modal-open class from body", () => {
      controller.closeModal()
      expect(document.body.classList.contains("modal-open")).toBe(false)
    })

    it("clears the form", () => {
      controller.messageTarget.value = "Test message"
      controller.contextTarget.value = "Test context"

      controller.closeModal()

      expect(controller.messageTarget.value).toBe("")
      expect(controller.contextTarget.value).toBe("")
    })
  })

  describe("submitForm", () => {
    beforeEach(() => {
      // Mock fetch
      global.fetch = jest.fn()
    })

    it("submits form data", async () => {
      const mockResponse = { success: true, message: "Success" }
      global.fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse
      })

      controller.messageTarget.value = "Test message"
      controller.contextTarget.value = "Test context"

      const event = new Event("submit")
      await controller.submitForm(event)

      expect(global.fetch).toHaveBeenCalledWith("/tdx_feedback_gem/feedbacks", expect.any(Object))
    })

    it("handles validation errors", async () => {
      controller.messageTarget.value = ""

      const event = new Event("submit")
      const result = await controller.submitForm(event)

      expect(result).toBe(false)
      expect(global.fetch).not.toHaveBeenCalled()
    })

    it("shows loading state during submission", async () => {
      const mockResponse = { success: true, message: "Success" }
      global.fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => mockResponse
      })

      controller.messageTarget.value = "Test message"

      const event = new Event("submit")
      const submitPromise = controller.submitForm(event)

      // Check loading state
      expect(controller.submitButtonTarget.disabled).toBe(true)

      await submitPromise

      // Check loading state cleared
      expect(controller.submitButtonTarget.disabled).toBe(false)
    })
  })

  describe("form validation", () => {
    it("validates required fields", () => {
      controller.messageTarget.value = ""

      const isValid = controller.validateForm()

      expect(isValid).toBe(false)
    })

    it("validates message length", () => {
      controller.messageTarget.value = "a".repeat(10001)

      const isValid = controller.validateForm()

      expect(isValid).toBe(false)
    })

    it("allows valid input", () => {
      controller.messageTarget.value = "Valid message"
      controller.contextTarget.value = "Valid context"

      const isValid = controller.validateForm()

      expect(isValid).toBe(true)
    })
  })
})
```

## 🔧 Test Utilities and Helpers

### Custom Matchers

```ruby
# spec/support/custom_matchers.rb
RSpec::Matchers.define :have_tdx_ticket do
  match do |feedback|
    feedback.tdx_ticket_id.present?
  end

  failure_message do |feedback|
    "expected feedback #{feedback.id} to have a TDX ticket, but it didn't"
  end

  failure_message_when_negated do |feedback|
    "expected feedback #{feedback.id} not to have a TDX ticket, but it had #{feedback.tdx_ticket_id}"
  end
end

RSpec::Matchers.define :be_submitted_by do |user|
  match do |feedback|
    feedback.user == user
  end

  failure_message do |feedback|
    "expected feedback to be submitted by #{user.email}, but it was submitted by #{feedback.user&.email || 'anonymous'}"
  end
end
```

### Test Data Builders

```ruby
# spec/support/test_data_builders.rb
module TestDataBuilders
  def build_feedback_with_context(context_type)
    case context_type
    when :bug_report
      build(:tdx_feedback_gem_feedback, :bug_report)
    when :feature_request
      build(:tdx_feedback_gem_feedback, :feature_request)
    when :general_feedback
      build(:tdx_feedback_gem_feedback, :general_feedback)
    else
      build(:tdx_feedback_gem_feedback)
    end
  end

  def create_feedback_batch(count, user: nil)
    count.times.map do |i|
      create(:tdx_feedback_gem_feedback,
        message: "Batch feedback #{i + 1}",
        user: user
      )
    end
  end

  def create_feedback_with_tdx_ticket(user: nil)
    feedback = create(:tdx_feedback_gem_feedback, user: user)
    feedback.update!(tdx_ticket_id: "TDX-#{SecureRandom.hex(4).upcase}")
    feedback
  end
end

RSpec.configure do |config|
  config.include TestDataBuilders
end
```

## 📊 Performance Testing

### Performance Test Examples

```ruby
# spec/performance/feedback_performance_spec.rb
require 'rails_helper'

RSpec.describe 'Feedback Performance', type: :performance do
  before do
    disable_tdx_in_tests
  end

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

  it 'handles large feedback messages efficiently' do
    large_message = "a" * 10000

    expect {
      post '/tdx_feedback_gem/feedbacks', params: {
        feedback: { message: large_message }
      }
    }.to change(TdxFeedbackGem::Feedback, :count).by(1)
  end

  it 'processes feedback batch efficiently' do
    feedbacks = create_feedback_batch(100)

    start_time = Time.current

    feedbacks.each(&:reload)

    duration = ((Time.current - start_time) * 1000).round
    expect(duration).to be < 50 # Should process in under 50ms
  end
end
```

## 🧹 Test Cleanup and Maintenance

### Database Cleanup

```ruby
# spec/support/database_cleanup.rb
RSpec.configure do |config|
  config.before(:suite) do
    # Clean up any existing test data
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:suite) do
    # Final cleanup
    DatabaseCleaner.clean_with(:truncation)
  end

  config.after(:each) do
    # Clean up after each test
    DatabaseCleaner.clean

    # Clear any cached data
    Rails.cache.clear if defined?(Rails.cache)
  end
end
```

### Test File Organization

```bash
spec/
├── factories/                    # Factory definitions
│   ├── tdx_feedback_gem_feedbacks.rb
│   └── users.rb
├── models/                       # Model tests
│   └── tdx_feedback_gem/
│       └── feedback_spec.rb
├── controllers/                  # Controller tests
│   └── tdx_feedback_gem/
│       └── feedbacks_controller_spec.rb
├── requests/                     # Request/Integration tests
│   └── feedback_flow_spec.rb
├── javascript/                   # JavaScript tests
│   └── controllers/
│       └── tdx_feedback_controller.test.js
├── performance/                  # Performance tests
│   └── feedback_performance_spec.rb
├── support/                      # Test helpers and configuration
│   ├── custom_matchers.rb
│   ├── database_cleanup.rb
│   ├── tdx_feedback_gem_test_helpers.rb
│   └── test_data_builders.rb
├── rails_helper.rb               # RSpec configuration
└── spec_helper.rb                # Basic RSpec setup
```

## 🚀 Running Tests

### Basic Test Commands

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/feedback_spec.rb

# Run tests matching a pattern
bundle exec rspec --example "validates message presence"

# Run tests with coverage
COVERAGE=true bundle exec rspec

# Run tests in parallel
bundle exec parallel_rspec spec/

# Run specific test line
bundle exec rspec spec/models/feedback_spec.rb:25
```

### Test Environment Variables

```bash
# Enable detailed logging
RSPEC_LOG_LEVEL=debug bundle exec rspec

# Run only fast tests
RSPEC_FAST_ONLY=true bundle exec rspec

# Skip slow tests
RSPEC_SKIP_SLOW=true bundle exec rspec

# Run with specific seed
RSPEC_SEED=12345 bundle exec rspec
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

    - name: Set up database
      run: |
        bundle exec rails db:create RAILS_ENV=test
        bundle exec rails db:migrate RAILS_ENV=test
        bundle exec rails db:test:prepare

    - name: Run tests
      run: bundle exec rspec

    - name: Run JavaScript tests
      run: npm test
```

## 🔄 Next Steps

Now that you understand testing:

1. **[Development Setup](Development-Setup)** - Set up your development environment
2. **[Contributing Guidelines](Contributing)** - Learn contribution standards
3. **[Performance Optimization](Performance-Optimization)** - Optimize test performance
4. **[Advanced Customization](Advanced-Customization)** - Test custom features

## 🆘 Need Help?

- Check the [Troubleshooting Guide](Troubleshooting)
- Review [Development Setup](Development-Setup) for test environment setup
- [Open an issue](https://github.com/lsa-mis/tdx-feedback_gem/issues) on GitHub
- Join the development discussion

---

*For more details about development setup, see the [Development Setup](Development-Setup) guide.*
