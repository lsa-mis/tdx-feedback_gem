# frozen_string_literal: true

require 'spec_helper'
require 'tdx_feedback_gem/configuration'

RSpec.describe TdxFeedbackGem::Configuration do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values correctly' do
      expect(config.require_authentication).to be false
      expect(config.tdx_base_url).to be_nil
      expect(config.oauth_token_url).to be_nil
      expect(config.client_id).to be_nil
      expect(config.client_secret).to be_nil
      expect(config.oauth_scope).to eq('tdxticket')
      expect(config.enable_ticket_creation).to be false
      expect(config.app_id).to be_nil
      expect(config.type_id).to be_nil
      expect(config.status_id).to be_nil
      expect(config.source_id).to be_nil
      expect(config.service_id).to be_nil
      expect(config.responsible_group_id).to be_nil
      expect(config.title_prefix).to eq('[Feedback]')
      expect(config.default_requestor_email).to be_nil
    end
  end

  describe 'attribute accessors' do
    it 'allows reading and writing require_authentication' do
      config.require_authentication = true
      expect(config.require_authentication).to be true

      config.require_authentication = false
      expect(config.require_authentication).to be false
    end

    it 'allows reading and writing TDX API settings' do
      config.tdx_base_url = 'https://api.example.com'
      config.oauth_token_url = 'https://api.example.com/oauth/token'
      config.client_id = 'test_client_id'
      config.client_secret = 'test_client_secret'
      config.oauth_scope = 'custom_scope'

      expect(config.tdx_base_url).to eq('https://api.example.com')
      expect(config.oauth_token_url).to eq('https://api.example.com/oauth/token')
      expect(config.client_id).to eq('test_client_id')
      expect(config.client_secret).to eq('test_client_secret')
      expect(config.oauth_scope).to eq('custom_scope')
    end

    it 'allows reading and writing ticket creation settings' do
      config.enable_ticket_creation = true
      config.app_id = 123
      config.type_id = 456
      config.status_id = 789
      config.source_id = 101
      config.service_id = 112
      config.responsible_group_id = 131
      config.title_prefix = '[Custom]'
      config.default_requestor_email = 'feedback@example.com'

      expect(config.enable_ticket_creation).to be true
      expect(config.app_id).to eq(123)
      expect(config.type_id).to eq(456)
      expect(config.status_id).to eq(789)
      expect(config.source_id).to eq(101)
      expect(config.service_id).to eq(112)
      expect(config.responsible_group_id).to eq(131)
      expect(config.title_prefix).to eq('[Custom]')
      expect(config.default_requestor_email).to eq('feedback@example.com')
    end
  end

  describe 'attribute types' do
    it 'handles boolean values for require_authentication' do
      config.require_authentication = true
      expect(config.require_authentication).to be true

      config.require_authentication = false
      expect(config.require_authentication).to be false

      config.require_authentication = 1
      expect(config.require_authentication).to eq(1)
    end

    it 'handles string values for URLs' do
      config.tdx_base_url = 'https://api.example.com'
      expect(config.tdx_base_url).to eq('https://api.example.com')

      config.tdx_base_url = nil
      expect(config.tdx_base_url).to be_nil

      config.tdx_base_url = ''
      expect(config.tdx_base_url).to eq('')
    end

    it 'handles integer values for IDs' do
      config.app_id = 123
      expect(config.app_id).to eq(123)

      config.app_id = '456'
      expect(config.app_id).to eq('456')

      config.app_id = nil
      expect(config.app_id).to be_nil
    end

    it 'handles string values for text fields' do
      config.title_prefix = '[Custom]'
      expect(config.title_prefix).to eq('[Custom]')

      config.title_prefix = ''
      expect(config.title_prefix).to eq('')

      config.title_prefix = nil
      expect(config.title_prefix).to be_nil
    end
  end

  describe 'edge cases' do
    it 'handles empty strings' do
      config.title_prefix = ''
      expect(config.title_prefix).to eq('')

      config.default_requestor_email = ''
      expect(config.default_requestor_email).to eq('')
    end

    it 'handles nil values' do
      config.tdx_base_url = nil
      expect(config.tdx_base_url).to be_nil

      config.app_id = nil
      expect(config.app_id).to be_nil
    end

    it 'handles special characters in strings' do
      config.title_prefix = '[Feedback] - Special: @#$%^&*()'
      expect(config.title_prefix).to eq('[Feedback] - Special: @#$%^&*()')

      config.default_requestor_email = 'test+tag@example.com'
      expect(config.default_requestor_email).to eq('test+tag@example.com')
    end

    it 'handles very long strings' do
      long_string = 'A' * 1000
      config.title_prefix = long_string
      expect(config.title_prefix).to eq(long_string)
    end

    it 'handles unicode characters' do
      config.title_prefix = '[Feedback] - 测试 - 🚀'
      expect(config.title_prefix).to eq('[Feedback] - 测试 - 🚀')
    end
  end

  describe 'configuration validation' do
    it 'allows all attributes to be set to valid values' do
      expect {
        config.require_authentication = true
        config.tdx_base_url = 'https://api.example.com'
        config.oauth_token_url = 'https://api.example.com/oauth/token'
        config.client_id = 'test_client_id'
        config.client_secret = 'test_client_secret'
        config.oauth_scope = 'custom_scope'
        config.enable_ticket_creation = true
        config.app_id = 123
        config.type_id = 456
        config.status_id = 789
        config.source_id = 101
        config.service_id = 112
        config.responsible_group_id = 131
        config.title_prefix = '[Custom]'
        config.default_requestor_email = 'feedback@example.com'
      }.not_to raise_error
    end

    it 'maintains configuration state across multiple assignments' do
      config.require_authentication = true
      config.tdx_base_url = 'https://api.example.com'

      # Verify state is maintained
      expect(config.require_authentication).to be true
      expect(config.tdx_base_url).to eq('https://api.example.com')

      # Change some values
      config.require_authentication = false
      config.tdx_base_url = 'https://new-api.example.com'

      # Verify new state
      expect(config.require_authentication).to be false
      expect(config.tdx_base_url).to eq('https://new-api.example.com')
    end
  end

  describe 'configuration scenarios' do
    context 'minimal configuration' do
      it 'works with only required fields set' do
        config.require_authentication = false
        config.enable_ticket_creation = false

        expect(config.require_authentication).to be false
        expect(config.enable_ticket_creation).to be false
        expect(config.tdx_base_url).to be_nil
      end
    end

    context 'full TDX configuration' do
      it 'works with all TDX fields set' do
        config.tdx_base_url = 'https://api.example.com'
        config.oauth_token_url = 'https://api.example.com/oauth/token'
        config.client_id = 'test_client_id'
        config.client_secret = 'test_client_secret'
        config.oauth_scope = 'tdxticket'

        expect(config.tdx_base_url).to eq('https://api.example.com')
        expect(config.oauth_token_url).to eq('https://api.example.com/oauth/token')
        expect(config.client_id).to eq('test_client_id')
        expect(config.client_secret).to eq('test_client_secret')
        expect(config.oauth_scope).to eq('tdxticket')
      end
    end

    context 'full ticket creation configuration' do
      it 'works with all ticket creation fields set' do
        config.enable_ticket_creation = true
        config.app_id = 123
        config.type_id = 456
        config.status_id = 789
        config.source_id = 101
        config.service_id = 112
        config.responsible_group_id = 131
        config.title_prefix = '[Custom]'
        config.default_requestor_email = 'feedback@example.com'

        expect(config.enable_ticket_creation).to be true
        expect(config.app_id).to eq(123)
        expect(config.type_id).to eq(456)
        expect(config.status_id).to eq(789)
        expect(config.source_id).to eq(101)
        expect(config.service_id).to eq(112)
        expect(config.responsible_group_id).to eq(131)
        expect(config.title_prefix).to eq('[Custom]')
        expect(config.default_requestor_email).to eq('feedback@example.com')
      end
    end
  end

  describe 'configuration persistence' do
    it 'maintains values across method calls' do
      config.require_authentication = true
      config.tdx_base_url = 'https://api.example.com'

      # Call some methods that don't modify the config
      expect(config.require_authentication).to be true
      expect(config.tdx_base_url).to eq('https://api.example.com')

      # Values should still be the same
      expect(config.require_authentication).to be true
      expect(config.tdx_base_url).to eq('https://api.example.com')
    end
  end

  describe 'object identity' do
    it 'maintains the same object instance' do
      config.require_authentication = true
      config_id = config.object_id

      config.tdx_base_url = 'https://api.example.com'
      expect(config.object_id).to eq(config_id)

      config.enable_ticket_creation = true
      expect(config.object_id).to eq(config_id)
    end
  end
end
