# frozen_string_literal: true

require 'spec_helper'

require 'tdx_feedback_gem/ticket_creator'
require 'tdx_feedback_gem/client'
require_relative '../app/models/tdx_feedback_gem/feedback'

RSpec.describe TdxFeedbackGem::TicketCreator do
  let(:config) do
    TdxFeedbackGem::Configuration.new.tap do |c|
      c.enable_ticket_creation = true
      c.app_id = 31
      c.type_id = 12
      c.form_id = 45
      c.service_offering_id = 89
      c.status_id = 77
      c.source_id = 8
      c.service_id = 67
      c.responsible_group_id = 631
      c.account_id = 2
      c.title_prefix = '[Feedback]'
      c.default_requestor_email = 'noreply@example.com'
      c.tdx_base_url = 'https://example.test'
      c.oauth_token_url = 'https://example.test/oauth/token'
      c.client_id = 'id'
      c.client_secret = 'secret'
    end
  end

  let(:stub_client) do
    Class.new do
      attr_reader :last_payload, :last_app_id

      def create_ticket(app_id:, payload: {})
        @last_app_id = app_id
        @last_payload = payload
        { 'ID' => 12_345 }
      end
    end.new
  end

  let(:feedback) { TdxFeedbackGem::Feedback.create!(message: 'Hello world', context: 'ctx') }

  describe '#initialize' do
    it 'accepts config and client parameters' do
      creator = described_class.new(config: config, client: stub_client)
      expect(creator.instance_variable_get(:@config)).to eq(config)
      expect(creator.instance_variable_get(:@client)).to eq(stub_client)
    end

    it 'builds client from config when client not provided' do
      creator = described_class.new(config: config)
      expect(creator.instance_variable_get(:@client)).to be_a(TdxFeedbackGem::Client)
    end

    it 'uses default config when config not provided' do
      creator = described_class.new(client: stub_client)
      expect(creator.instance_variable_get(:@config)).to eq(TdxFeedbackGem.config)
    end
  end

  describe '#call' do
    let(:creator) { described_class.new(config: config, client: stub_client) }

    context 'when ticket creation is enabled' do
      it 'builds a payload and returns ticket id' do
        result = creator.call(feedback)
        expect(result.success?).to be true
        expect(result.ticket_id).to eq(12_345)
        expect(stub_client.last_app_id).to eq(31)
        expect(stub_client.last_payload['Title']).to start_with('[Feedback]')
        expect(stub_client.last_payload['RequestorEmail']).to eq('noreply@example.com')
      end

      it 'includes all required ticket fields' do
        result = creator.call(feedback)
        expect(result.success?).to be true

        payload = stub_client.last_payload
        expect(payload['TypeID']).to eq(12)
        expect(payload['FormID']).to eq(45)
        expect(payload['ServiceOfferingID']).to eq(89)
        expect(payload['StatusID']).to eq(77)
        expect(payload['SourceID']).to eq(8)
        expect(payload['ServiceID']).to eq(67)
        expect(payload['ResponsibleGroupID']).to eq(631)
        expect(payload['AccountID']).to eq(2)
        expect(payload['Title']).to start_with('[Feedback]')
        expect(payload['Description']).to include('Hello world')
        expect(payload['Description']).to include('ctx')
        expect(payload['IsRichHtml']).to be false
      end

      it 'truncates long messages in title' do
        long_message = 'A' * 100
        feedback.update!(message: long_message)

        result = creator.call(feedback)
        expect(result.success?).to be true

        title = stub_client.last_payload['Title']
        expect(title).to start_with('[Feedback]')
        expect(title.length).to be <= 100 # Title should be truncated
      end

      it 'handles messages with newlines in title' do
        feedback.update!(message: "Line 1\nLine 2\nLine 3")

        result = creator.call(feedback)
        expect(result.success?).to be true

        title = stub_client.last_payload['Title']
        # The tr method should replace newlines with spaces
        expect(title).to start_with('[Feedback]')
        expect(title).to include('Line 1')
        expect(title).to include('Line 2')
        expect(title).to include('Line 3')
        # Check that newlines are replaced with spaces
        expect(title).not_to include("\n")
        # The title should contain the message with spaces instead of newlines
        expect(title).to include('Line 1 Line 2 Line 3')
      end

      it 'builds description with message and context' do
        result = creator.call(feedback)
        expect(result.success?).to be true

        description = stub_client.last_payload['Description']
        expect(description).to start_with('Hello world')
        expect(description).to include('--- Context ---')
        expect(description).to include('ctx')
      end

      it 'builds description with only message when no context' do
        feedback.update!(context: nil)

        result = creator.call(feedback)
        expect(result.success?).to be true

        description = stub_client.last_payload['Description']
        expect(description).to eq('Hello world')
        expect(description).not_to include('--- Context ---')
      end

      it 'builds description with empty context' do
        feedback.update!(context: '')

        result = creator.call(feedback)
        expect(result.success?).to be true

        description = stub_client.last_payload['Description']
        expect(description).to eq('Hello world')
        expect(description).not_to include('--- Context ---')
      end

      it 'uses provided requestor email when available' do
        result = creator.call(feedback, requestor_email: 'custom@example.com')
        expect(result.success?).to be true
        expect(stub_client.last_payload['RequestorEmail']).to eq('custom@example.com')
      end

      it 'falls back to default requestor email when none provided' do
        result = creator.call(feedback)
        expect(result.success?).to be true
        expect(stub_client.last_payload['RequestorEmail']).to eq('noreply@example.com')
      end

      it 'handles nil requestor email gracefully' do
        config.default_requestor_email = nil

        result = creator.call(feedback)
        expect(result.success?).to be true
        expect(stub_client.last_payload).not_to have_key('RequestorEmail')
      end

      it 'merges extra attributes into payload' do
        extra_attrs = { 'Priority' => 'High', 'Category' => 'Bug' }

        result = creator.call(feedback, extra_attributes: extra_attrs)
        expect(result.success?).to be true

        payload = stub_client.last_payload
        expect(payload['Priority']).to eq('High')
        expect(payload['Category']).to eq('Bug')
      end

      it 'stringifies extra attribute keys' do
        extra_attrs = { priority: 'High', category: 'Bug' }

        result = creator.call(feedback, extra_attributes: extra_attrs)
        expect(result.success?).to be true

        payload = stub_client.last_payload
        expect(payload['priority']).to eq('High')
        expect(payload['category']).to eq('Bug')
      end

      it 'handles empty extra attributes' do
        result = creator.call(feedback, extra_attributes: {})
        expect(result.success?).to be true

        # Should not affect the payload
        expect(stub_client.last_payload['Title']).to be_present
      end

      it 'handles nil extra attributes' do
        result = creator.call(feedback, extra_attributes: nil)
        expect(result.success?).to be true

        # Should not affect the payload
        expect(stub_client.last_payload['Title']).to be_present
      end

      it 'includes AccountID when configured' do
        result = creator.call(feedback)
        expect(result.success?).to be true

        payload = stub_client.last_payload
        expect(payload['AccountID']).to eq(2)
      end

      it 'excludes AccountID when not configured' do
        config.account_id = nil

        result = creator.call(feedback)
        expect(result.success?).to be true

        payload = stub_client.last_payload
        expect(payload).not_to have_key('AccountID')
      end
    end

    context 'when ticket creation is disabled' do
      before { config.enable_ticket_creation = false }

      it 'returns failure result with appropriate error message' do
        result = creator.call(feedback)
        expect(result.success?).to be false
        expect(result.ticket_id).to be_nil
        expect(result.error).to eq('Ticket creation disabled')
      end

      it 'does not call the client' do
        expect(stub_client).not_to receive(:create_ticket)
        creator.call(feedback)
      end
    end

    context 'when client raises an error' do
      before do
        allow(stub_client).to receive(:create_ticket).and_raise(StandardError.new('API Error'))
      end

      it 'returns failure result with error details' do
        result = creator.call(feedback)
        expect(result.success?).to be false
        expect(result.ticket_id).to be_nil
        expect(result.error).to be_a(StandardError)
        expect(result.error.message).to eq('API Error')
      end
    end

    context 'with different response formats' do
      it 'handles response with ID at root level' do
        allow(stub_client).to receive(:create_ticket).and_return({ 'ID' => 999 })

        result = creator.call(feedback)
        expect(result.success?).to be true
        expect(result.ticket_id).to eq(999)
      end

      it 'handles response with ID in data object' do
        allow(stub_client).to receive(:create_ticket).and_return({ 'data' => { 'ID' => 888 } })

        result = creator.call(feedback)
        expect(result.success?).to be true
        expect(result.ticket_id).to eq(888)
      end

      it 'handles response without ID' do
        allow(stub_client).to receive(:create_ticket).and_return({ 'status' => 'success' })

        result = creator.call(feedback)
        expect(result.success?).to be true
        expect(result.ticket_id).to be_nil
      end
    end
  end

  describe 'Result struct' do
    it 'has the expected attributes' do
      result = TdxFeedbackGem::TicketCreator::Result.new(true, 123, {}, nil)
      expect(result.success?).to be true
      expect(result.ticket_id).to eq(123)
      expect(result.response).to eq({})
      expect(result.error).to be_nil
    end

    it 'can be created with different combinations' do
      result = TdxFeedbackGem::TicketCreator::Result.new(false, nil, nil, 'Error message')
      expect(result.success?).to be false
      expect(result.ticket_id).to be_nil
      expect(result.response).to be_nil
      expect(result.error).to eq('Error message')
    end
  end

  describe 'private methods' do
    let(:creator) { described_class.new(config: config, client: stub_client) }

    describe '#build_description' do
      it 'combines message and context with separator' do
        description = creator.send(:build_description, feedback)
        expect(description).to eq("Hello world\n--- Context ---\nctx")
      end

      it 'handles nil context' do
        feedback.update!(context: nil)
        description = creator.send(:build_description, feedback)
        expect(description).to eq('Hello world')
      end

      it 'handles empty context' do
        feedback.update!(context: '')
        description = creator.send(:build_description, feedback)
        expect(description).to eq('Hello world')
      end

      it 'handles whitespace-only context' do
        feedback.update!(context: '   ')
        description = creator.send(:build_description, feedback)
        expect(description).to eq('Hello world')
      end
    end

    describe '#stringify_keys' do
      it 'converts symbol keys to strings' do
        hash = { key1: 'value1', key2: 'value2' }
        result = creator.send(:stringify_keys, hash)
        expect(result).to eq({ 'key1' => 'value1', 'key2' => 'value2' })
      end

      it 'handles mixed key types' do
        hash = { symbol_key: 'value1', 'string_key' => 'value2', 123 => 'value3' }
        result = creator.send(:stringify_keys, hash)
        expect(result).to eq({ 'symbol_key' => 'value1', 'string_key' => 'value2', '123' => 'value3' })
      end

      it 'handles empty hash' do
        result = creator.send(:stringify_keys, {})
        expect(result).to eq({})
      end
    end
  end
end
