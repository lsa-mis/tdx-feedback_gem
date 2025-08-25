# frozen_string_literal: true

require 'tdx_feedback_gem'

RSpec.describe TdxFeedbackGem do
  describe 'version' do
    it 'has a version number' do
      expect(TdxFeedbackGem::VERSION).not_to be nil
      expect(TdxFeedbackGem::VERSION).to be_a(String)
      expect(TdxFeedbackGem::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe 'configuration' do
    after do
      # Restore original configuration
      TdxFeedbackGem.configure do |c|
        c.require_authentication = false
        c.enable_ticket_creation = false
        c.tdx_base_url = nil
        c.oauth_token_url = nil
        c.client_id = nil
        c.client_secret = nil
        c.oauth_scope = 'tdxticket'
        c.app_id = nil
        c.type_id = nil
        c.status_id = nil
        c.source_id = nil
        c.service_id = nil
        c.responsible_group_id = nil
        c.title_prefix = '[Feedback]'
        c.default_requestor_email = nil
      end
    end

    describe 'require_authentication' do
      it 'has a default value of false' do
        expect(TdxFeedbackGem.config.require_authentication).to be false
      end

      it 'can be configured to true' do
        TdxFeedbackGem.configure { |c| c.require_authentication = true }
        expect(TdxFeedbackGem.config.require_authentication).to be true
      end

      it 'can be configured to false' do
        TdxFeedbackGem.configure { |c| c.require_authentication = false }
        expect(TdxFeedbackGem.config.require_authentication).to be false
      end
    end

    describe 'TDX API configuration' do
      it 'has default TDX API settings' do
        expect(TdxFeedbackGem.config.tdx_base_url).to be_nil
        expect(TdxFeedbackGem.config.oauth_token_url).to be_nil
        expect(TdxFeedbackGem.config.client_id).to be_nil
        expect(TdxFeedbackGem.config.client_secret).to be_nil
        expect(TdxFeedbackGem.config.oauth_scope).to eq('tdxticket')
      end

      it 'can configure TDX API settings' do
        TdxFeedbackGem.configure do |c|
          c.tdx_base_url = 'https://api.example.com'
          c.oauth_token_url = 'https://api.example.com/oauth/token'
          c.client_id = 'test_client_id'
          c.client_secret = 'test_client_secret'
          c.oauth_scope = 'custom_scope'
        end

        expect(TdxFeedbackGem.config.tdx_base_url).to eq('https://api.example.com')
        expect(TdxFeedbackGem.config.oauth_token_url).to eq('https://api.example.com/oauth/token')
        expect(TdxFeedbackGem.config.client_id).to eq('test_client_id')
        expect(TdxFeedbackGem.config.client_secret).to eq('test_client_secret')
        expect(TdxFeedbackGem.config.oauth_scope).to eq('custom_scope')
      end
    end

    describe 'ticket creation configuration' do
      it 'has default ticket creation settings' do
        expect(TdxFeedbackGem.config.enable_ticket_creation).to be false
        expect(TdxFeedbackGem.config.app_id).to be_nil
        expect(TdxFeedbackGem.config.type_id).to be_nil
        expect(TdxFeedbackGem.config.status_id).to be_nil
        expect(TdxFeedbackGem.config.source_id).to be_nil
        expect(TdxFeedbackGem.config.service_id).to be_nil
        expect(TdxFeedbackGem.config.responsible_group_id).to be_nil
        expect(TdxFeedbackGem.config.title_prefix).to eq('[Feedback]')
        expect(TdxFeedbackGem.config.default_requestor_email).to be_nil
      end

      it 'can configure ticket creation settings' do
        TdxFeedbackGem.configure do |c|
          c.enable_ticket_creation = true
          c.app_id = 123
          c.type_id = 456
          c.status_id = 789
          c.source_id = 101
          c.service_id = 112
          c.responsible_group_id = 131
          c.title_prefix = '[Custom]'
          c.default_requestor_email = 'feedback@example.com'
        end

        expect(TdxFeedbackGem.config.enable_ticket_creation).to be true
        expect(TdxFeedbackGem.config.app_id).to eq(123)
        expect(TdxFeedbackGem.config.type_id).to eq(456)
        expect(TdxFeedbackGem.config.status_id).to eq(789)
        expect(TdxFeedbackGem.config.source_id).to eq(101)
        expect(TdxFeedbackGem.config.service_id).to eq(112)
        expect(TdxFeedbackGem.config.responsible_group_id).to eq(131)
        expect(TdxFeedbackGem.config.title_prefix).to eq('[Custom]')
        expect(TdxFeedbackGem.config.default_requestor_email).to eq('feedback@example.com')
      end
    end

    describe 'configuration persistence' do
      it 'maintains configuration across multiple calls' do
        TdxFeedbackGem.configure { |c| c.require_authentication = true }
        expect(TdxFeedbackGem.config.require_authentication).to be true

        # Verify configuration persists
        expect(TdxFeedbackGem.config.require_authentication).to be true
      end

      it 'allows multiple configuration blocks' do
        TdxFeedbackGem.configure { |c| c.require_authentication = true }
        TdxFeedbackGem.configure { |c| c.enable_ticket_creation = true }

        expect(TdxFeedbackGem.config.require_authentication).to be true
        expect(TdxFeedbackGem.config.enable_ticket_creation).to be true
      end
    end

    describe 'configuration instance' do
      it 'returns the same configuration instance' do
        config1 = TdxFeedbackGem.config
        config2 = TdxFeedbackGem.config
        expect(config1).to be(config2)
      end

      it 'allows direct configuration modification' do
        config = TdxFeedbackGem.config
        config.require_authentication = true
        expect(TdxFeedbackGem.config.require_authentication).to be true
      end
    end
  end

  describe 'module structure' do
    it 'defines the expected classes' do
      expect(defined?(TdxFeedbackGem::Configuration)).to be_truthy
      expect(defined?(TdxFeedbackGem::Feedback)).to be_truthy
      expect(defined?(TdxFeedbackGem::FeedbacksController)).to be_truthy
      expect(defined?(TdxFeedbackGem::TicketCreator)).to be_truthy
      expect(defined?(TdxFeedbackGem::Client)).to be_truthy
    end
  end
end
