# frozen_string_literal: true

require 'spec_helper'
require 'tdx_feedback_gem/configuration'

RSpec.describe TdxFeedbackGem::Configuration do
  let(:config) { described_class.new }

  describe '#initialize' do
    it 'sets default values correctly' do
      expect(config.require_authentication).to be false
      # URLs are now automatically resolved from credentials, ENV, or defaults
      expect(config.tdx_base_url).to be_a(String)
      expect(config.oauth_token_url).to be_a(String)
      # client_id and client_secret are resolved from credentials or ENV, so they may not be nil
      expect(config.client_id).to eq(nil).or eq(ENV['TDX_CLIENT_ID'])
      expect(config.client_secret).to eq(nil).or eq(ENV['TDX_CLIENT_SECRET'])
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
      expect(config.account_id).to eq(nil).or eq(ENV['TDX_ACCOUNT_ID']&.to_i)
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
        # URLs are automatically resolved from credentials, ENV, or defaults
        expect(config.tdx_base_url).to be_a(String)
        expect(config.oauth_token_url).to be_a(String)
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

  describe 'credential resolution' do
    let(:original_env_client_id) { ENV['TDX_CLIENT_ID'] }
    let(:original_env_client_secret) { ENV['TDX_CLIENT_SECRET'] }

    before do
      ENV['TDX_CLIENT_ID'] = nil
      ENV['TDX_CLIENT_SECRET'] = nil
    end

    after do
      ENV['TDX_CLIENT_ID'] = original_env_client_id
      ENV['TDX_CLIENT_SECRET'] = original_env_client_secret
    end

    context 'when Rails credentials are available' do
      let(:mock_credentials) { double('credentials') }

      before do
        allow(mock_credentials).to receive(:tdx_client_id).and_return('credentials_client_id')
        allow(mock_credentials).to receive(:tdx_client_secret).and_return('credentials_client_secret')
        allow(mock_credentials).to receive(:dig).and_return(nil)

        mock_app = double('application')
        allow(mock_app).to receive(:credentials).and_return(mock_credentials)

        mock_env = double('env')
        allow(mock_env).to receive(:production?).and_return(false)
        allow(mock_env).to receive(:staging?).and_return(false)
        allow(mock_env).to receive(:test?).and_return(true)
        allow(mock_env).to receive(:development?).and_return(false)

        stub_const('Rails', double('Rails'))
        allow(Rails).to receive(:application).and_return(mock_app)
        allow(Rails).to receive(:env).and_return(mock_env)
      end

      it 'uses Rails credentials over ENV variables' do
        ENV['TDX_CLIENT_ID'] = 'env_client_id'
        ENV['TDX_CLIENT_SECRET'] = 'env_client_secret'

        config = described_class.new

        expect(config.client_id).to eq('credentials_client_id')
        expect(config.client_secret).to eq('credentials_client_secret')
      end

      it 'uses Rails credentials when ENV variables are not set' do
        config = described_class.new

        expect(config.client_id).to eq('credentials_client_id')
        expect(config.client_secret).to eq('credentials_client_secret')
      end

      it 'falls back to ENV when Rails credentials return nil' do
        allow(mock_credentials).to receive(:tdx_client_id).and_return(nil)
        allow(mock_credentials).to receive(:tdx_client_secret).and_return(nil)

        ENV['TDX_CLIENT_ID'] = 'env_client_id'
        ENV['TDX_CLIENT_SECRET'] = 'env_client_secret'

        config = described_class.new

        expect(config.client_id).to eq('env_client_id')
        expect(config.client_secret).to eq('env_client_secret')
      end

      it 'falls back to ENV when Rails credentials return empty string' do
        allow(mock_credentials).to receive(:tdx_client_id).and_return('')
        allow(mock_credentials).to receive(:tdx_client_secret).and_return('')

        ENV['TDX_CLIENT_ID'] = 'env_client_id'
        ENV['TDX_CLIENT_SECRET'] = 'env_client_secret'

        config = described_class.new

        expect(config.client_id).to eq('env_client_id')
        expect(config.client_secret).to eq('env_client_secret')
      end
    end

    context 'when Rails credentials are not available' do
      before do
        # Ensure Rails is not defined
        if defined?(Rails)
          hide_const('Rails')
        end
      end

      it 'uses ENV variables when Rails is not available' do
        ENV['TDX_CLIENT_ID'] = 'env_client_id'
        ENV['TDX_CLIENT_SECRET'] = 'env_client_secret'

        config = described_class.new

        expect(config.client_id).to eq('env_client_id')
        expect(config.client_secret).to eq('env_client_secret')
      end

      it 'returns nil when neither Rails credentials nor ENV variables are available' do
        config = described_class.new

        expect(config.client_id).to be_nil
        expect(config.client_secret).to be_nil
      end
    end
  end

  describe 'URL resolution' do
    let(:original_env_base_url) { ENV['TDX_BASE_URL'] }
    let(:original_env_oauth_url) { ENV['TDX_OAUTH_TOKEN_URL'] }

    before do
      ENV['TDX_BASE_URL'] = nil
      ENV['TDX_OAUTH_TOKEN_URL'] = nil
    end

    after do
      ENV['TDX_BASE_URL'] = original_env_base_url
      ENV['TDX_OAUTH_TOKEN_URL'] = original_env_oauth_url
    end

    context 'when Rails credentials are available' do
      let(:mock_credentials) { double('credentials') }

      before do
        allow(mock_credentials).to receive(:tdx_client_id).and_return('credentials_client_id')
        allow(mock_credentials).to receive(:tdx_client_secret).and_return('credentials_client_secret')

        mock_app = double('application')
        allow(mock_app).to receive(:credentials).and_return(mock_credentials)

        stub_const('Rails', double('Rails'))
        allow(Rails).to receive(:application).and_return(mock_app)
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      end

      context 'with environment-specific credentials' do
        before do
          allow(mock_credentials).to receive(:dig).and_return(nil)
          allow(mock_credentials).to receive(:dig)
            .with(:tdx, :development, :base_url)
            .and_return('https://dev.api.example.com/um/it')
          allow(mock_credentials).to receive(:dig)
            .with(:tdx, :development, :oauth_token_url)
            .and_return('https://dev.api.example.com/um/oauth2/token')

          # Override the parent Rails.env mock for this specific test
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        end

        it 'uses environment-specific credentials for development' do
          config = described_class.new
          expect(config.tdx_base_url).to eq('https://dev.api.example.com/um/it')
          expect(config.oauth_token_url).to eq('https://dev.api.example.com/um/oauth2/token')
        end
      end

      context 'with general credentials' do
        before do
          allow(mock_credentials).to receive(:dig).and_return(nil)
          allow(mock_credentials).to receive(:dig)
            .with(:tdx, :base_url)
            .and_return('https://general.api.example.com/um/it')
          allow(mock_credentials).to receive(:dig)
            .with(:tdx, :oauth_token_url)
            .and_return('https://general.api.example.com/um/oauth2/token')
        end

        it 'uses general credentials when environment-specific ones are not available' do
          config = described_class.new
          expect(config.tdx_base_url).to eq('https://general.api.example.com/um/it')
          expect(config.oauth_token_url).to eq('https://general.api.example.com/um/oauth2/token')
        end
      end
    end

    context 'when Rails credentials are not available' do
      before do
        if defined?(Rails)
          hide_const('Rails')
        end
      end

      it 'uses ENV variables when Rails is not available' do
        ENV['TDX_BASE_URL'] = 'https://env.api.example.com/um/it'
        ENV['TDX_OAUTH_TOKEN_URL'] = 'https://env.api.example.com/um/oauth2/token'

        config = described_class.new
        expect(config.tdx_base_url).to eq('https://env.api.example.com/um/it')
        expect(config.oauth_token_url).to eq('https://env.api.example.com/um/oauth2/token')
      end

      it 'uses default URLs when neither credentials nor ENV are available' do
        config = described_class.new
        # Since Rails is not defined, it will use the default URL for non-production
        expect(config.tdx_base_url).to eq('https://gw-test.api.it.umich.edu/um/it')
        expect(config.oauth_token_url).to eq('https://gw-test.api.it.umich.edu/um/oauth2/token')
      end
    end

    context 'environment-specific defaults' do
      before do
        if defined?(Rails)
          hide_const('Rails')
        end
      end

      it 'uses test URLs for non-production environments' do
        # Without Rails defined, it defaults to test URLs
        config = described_class.new
        expect(config.tdx_base_url).to eq('https://gw-test.api.it.umich.edu/um/it')
        expect(config.oauth_token_url).to eq('https://gw-test.api.it.umich.edu/um/oauth2/token')
      end

      context 'when Rails environment is production' do
        before do
          mock_credentials = double('credentials')
          allow(mock_credentials).to receive(:tdx_client_id).and_return(nil)
          allow(mock_credentials).to receive(:tdx_client_secret).and_return(nil)
          allow(mock_credentials).to receive(:dig).and_return(nil)

          mock_app = double('application')
          allow(mock_app).to receive(:credentials).and_return(mock_credentials)

          stub_const('Rails', double('Rails'))
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
          allow(Rails).to receive(:application).and_return(mock_app)
        end

        it 'uses production URLs for production environment' do
          config = described_class.new
          expect(config.tdx_base_url).to eq('https://gw.api.it.umich.edu/um/it')
          expect(config.oauth_token_url).to eq('https://gw.api.it.umich.edu/um/oauth2/token')
        end
      end

      context 'when Rails environment is staging' do
        before do
          mock_credentials = double('credentials')
          allow(mock_credentials).to receive(:tdx_client_id).and_return(nil)
          allow(mock_credentials).to receive(:tdx_client_secret).and_return(nil)
          allow(mock_credentials).to receive(:dig).and_return(nil)

          mock_app = double('application')
          allow(mock_app).to receive(:credentials).and_return(mock_credentials)

          stub_const('Rails', double('Rails'))
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('staging'))
          allow(Rails).to receive(:application).and_return(mock_app)
        end

        it 'uses test URLs for staging environment' do
          config = described_class.new
          expect(config.tdx_base_url).to eq('https://gw-test.api.it.umich.edu/um/it')
          expect(config.oauth_token_url).to eq('https://gw-test.api.it.umich.edu/um/oauth2/token')
        end
      end
    end
  end

  describe '#resolve_credentials_after_initialization!' do
    before do
      # Mock Rails.application.credentials to return nil by default
      allow(Rails.application.credentials).to receive(:dig).and_return(nil)
      allow(Rails).to receive(:logger).and_return(double(info: nil))
    end

    it 're-resolves enable_ticket_creation from credentials' do
      allow(Rails.application.credentials).to receive(:dig).with(:tdx, :development, :enable_ticket_creation).and_return('true')

      config.resolve_credentials_after_initialization!

      expect(config.enable_ticket_creation).to be true
    end

    it 're-resolves account_id from credentials' do
      allow(Rails.application.credentials).to receive(:dig).with(:tdx, :development, :account_id).and_return('21')

      config.resolve_credentials_after_initialization!

      expect(config.account_id).to eq(21)
    end

    it 'logs the resolution results' do
      logger = double('logger')
      allow(Rails).to receive(:logger).and_return(logger)
      allow(Rails.application.credentials).to receive(:dig).with(:tdx, :development, :enable_ticket_creation).and_return('true')
      allow(Rails.application.credentials).to receive(:dig).with(:tdx, :development, :account_id).and_return('21')

      expect(logger).to receive(:info).with('TDX Feedback Gem: Resolved enable_ticket_creation=true from credentials/ENV')
      expect(logger).to receive(:info).with('TDX Feedback Gem: Resolved account_id=21 from credentials/ENV')

      config.resolve_credentials_after_initialization!
    end
  end

  describe 'account_id resolution' do
    before do
      allow(Rails).to receive(:env).and_return(double(development?: true, production?: false, staging?: false, test?: false))
      allow(Rails.application.credentials).to receive(:dig).and_return(nil)
      allow(ENV).to receive(:[]).and_return(nil)
    end

    it 'resolves account_id from environment-specific credentials' do
      allow(Rails.application.credentials).to receive(:dig).with(:tdx, :development, :account_id).and_return('21')

      account_id = config.send(:resolve_account_id)
      expect(account_id).to eq(21)
    end

    it 'resolves account_id from general credentials' do
      allow(Rails.application.credentials).to receive(:dig).with(:tdx, :account_id).and_return('42')

      account_id = config.send(:resolve_account_id)
      expect(account_id).to eq(42)
    end

    it 'resolves account_id from environment variable' do
      allow(ENV).to receive(:[]).with('TDX_ACCOUNT_ID').and_return('99')

      account_id = config.send(:resolve_account_id)
      expect(account_id).to eq(99)
    end

    it 'returns nil when no account_id is configured' do
      account_id = config.send(:resolve_account_id)
      expect(account_id).to be_nil
    end
  end
end
