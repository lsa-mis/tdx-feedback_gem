# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TdxFeedbackGem::Client do
  let(:base_url) { 'https://api.example.com' }
  let(:token_url) { 'https://auth.example.com/oauth/token' }
  let(:client_id) { 'test_client' }
  let(:client_secret) { 'test_secret' }
  let(:scope) { 'read write' }
  let(:client) { described_class.new(base_url: base_url, token_url: token_url, client_id: client_id, client_secret: client_secret, scope: scope) }
  let(:client_no_base) { described_class.new(base_url: nil, token_url: token_url, client_id: client_id, client_secret: client_secret, scope: scope) }

  describe '#initialize' do
    it 'sets instance variables correctly' do
      expect(client.instance_variable_get(:@base_url)).to eq(base_url)
      expect(client.instance_variable_get(:@token_url)).to eq(token_url)
      expect(client.instance_variable_get(:@client_id)).to eq(client_id)
      expect(client.instance_variable_get(:@client_secret)).to eq(client_secret)
      expect(client.instance_variable_get(:@scope)).to eq(scope)
    end
  end

  describe '#create_ticket' do
    let(:app_id) { 'test_app' }
    let(:payload) { { title: 'Test Ticket', description: 'Test Description' } }
    let(:params) { { priority: 'high' } }

    it 'creates a ticket successfully' do
      stub_request(:post, "#{base_url}/#{app_id}/tickets?priority=high")
        .with(
          body: payload.to_json,
          headers: { 'Authorization' => 'Bearer test_token', 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        )
        .to_return(status: 201, body: { id: '123', status: 'created' }.to_json)

      client.instance_variable_set(:@token, 'test_token')
      allow(client).to receive(:ensure_token!).and_return(nil)

      result = client.create_ticket(app_id: app_id, payload: payload, params: params)
      expect(result['id']).to eq('123')
    end
  end

  describe '#post_feed' do
    let(:app_id) { 'test_app' }
    let(:ticket_id) { '123' }
    let(:payload) { { message: 'Test feed message' } }

    it 'posts feed successfully' do
      stub_request(:post, "#{base_url}/#{app_id}/tickets/#{ticket_id}/feed")
        .with(
          body: payload.to_json,
          headers: { 'Authorization' => 'Bearer test_token', 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        )
        .to_return(status: 201, body: { id: '456', status: 'posted' }.to_json)

      client.instance_variable_set(:@token, 'test_token')
      allow(client).to receive(:ensure_token!).and_return(nil)

      result = client.post_feed(app_id: app_id, ticket_id: ticket_id, payload: payload)
      expect(result['id']).to eq('456')
    end
  end

  describe 'OAuth token management' do
    before do
      allow(client).to receive(:http_request).and_call_original
    end

    it 'obtains OAuth token successfully' do
      stub_request(:post, token_url)
        .with(
          basic_auth: [client_id, client_secret],
          body: { grant_type: 'client_credentials', scope: scope }
        )
        .to_return(
          status: 200,
          body: { access_token: 'new_token', expires_in: 3600 }.to_json
        )

      client.send(:ensure_token!)
      expect(client.instance_variable_get(:@token)).to eq('new_token')
    end

    it 'refreshes expired token' do
      client.instance_variable_set(:@token, 'old_token')
      client.instance_variable_set(:@token_expires_at, Time.now - 60)

      stub_request(:post, token_url)
        .with(
          basic_auth: [client_id, client_secret],
          body: { grant_type: 'client_credentials', scope: scope }
        )
        .to_return(
          status: 200,
          body: { access_token: 'refreshed_token', expires_in: 3600 }.to_json
        )

      client.send(:ensure_token!)
      expect(client.instance_variable_get(:@token)).to eq('refreshed_token')
    end

    it 'handles token refresh errors gracefully' do
      client.instance_variable_set(:@token, 'old_token')
      client.instance_variable_set(:@token_expires_at, Time.now - 60)

      stub_request(:post, token_url)
        .with(
          basic_auth: [client_id, client_secret],
          body: { grant_type: 'client_credentials', scope: scope }
        )
        .to_return(status: 500, body: 'Internal Server Error')

      expect {
        client.send(:ensure_token!)
      }.to raise_error(TdxFeedbackGem::Client::HttpError, /HTTP 500/)
    end

    it 'when OAuth request fails raises HttpError with appropriate message' do
      client.instance_variable_set(:@token, 'old_token')
      client.instance_variable_set(:@token_expires_at, Time.now - 60)

      stub_request(:post, token_url)
        .with(
          basic_auth: [client_id, client_secret],
          body: { grant_type: 'client_credentials', scope: scope }
        )
        .to_return(status: 401, body: 'Unauthorized')

      expect {
        client.send(:ensure_token!)
      }.to raise_error(TdxFeedbackGem::Client::HttpError, /HTTP 401/)
    end

    it 'handles malformed JSON response' do
      client.instance_variable_set(:@token, 'old_token')
      client.instance_variable_set(:@token_expires_at, Time.now - 60)

      stub_request(:post, token_url)
        .with(
          basic_auth: [client_id, client_secret],
          body: { grant_type: 'client_credentials', scope: scope }
        )
        .to_return(status: 200, body: 'invalid json')

      expect {
        client.send(:ensure_token!)
      }.to raise_error(TdxFeedbackGem::Client::HttpError, /OAuth token missing/)
    end
  end

  describe 'HTTP request handling' do
    before do
      client.instance_variable_set(:@token, 'test_token')
      allow(client).to receive(:ensure_token!).and_return(nil)
    end

    it 'handles successful responses' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 200, body: { success: true }.to_json)

      result = client.send(:get_json, '/test')
      expect(result['success']).to be true
    end

    it 'handles HTTP errors' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 404, body: 'Not Found')

      expect {
        client.send(:get_json, '/test')
      }.to raise_error(TdxFeedbackGem::Client::HttpError, /HTTP 404/)
    end

    it 'handles network timeouts' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_timeout

      expect {
        client.send(:get_json, '/test')
      }.to raise_error(Net::OpenTimeout)
    end

    it 'with network timeouts handles read timeout' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_timeout

      expect {
        client.send(:get_json, '/test')
      }.to raise_error(Net::OpenTimeout)
    end
  end

  describe 'JSON parsing' do
    before do
      client.instance_variable_set(:@token, 'test_token')
      allow(client).to receive(:ensure_token!).and_return(nil)
    end

    it 'parses valid JSON responses' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 200, body: { data: 'test' }.to_json)

      result = client.send(:get_json, '/test')
      expect(result['data']).to eq('test')
    end

    it 'handles empty response bodies' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 200, body: '')

      result = client.send(:get_json, '/test')
      expect(result).to eq({})
    end

    it 'handles malformed JSON gracefully' do
      stub_request(:get, "#{base_url}/test")
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 200, body: 'invalid json')

      result = client.send(:get_json, '/test')
      expect(result['raw']).to eq('invalid json')
    end
  end

  describe 'URI building' do
    it 'builds URI with query parameters' do
      uri = client.send(:build_uri, '/test', { param1: 'value1', param2: 'value2' })
      expect(uri.to_s).to eq("#{base_url}/test?param1=value1&param2=value2")
    end

    it 'builds URI without query parameters' do
      uri = client.send(:build_uri, '/test', {})
      expect(uri.to_s).to eq("#{base_url}/test")
    end

    it 'raises ArgumentError when base_url is missing' do
      expect {
        client_no_base.send(:build_uri, '/test', {})
      }.to raise_error(ArgumentError, 'base_url is missing')
    end
  end

  describe 'SSL configuration' do
    it 'enables SSL for HTTPS URLs' do
      https_client = described_class.new(base_url: 'https://api.example.com', token_url: token_url, client_id: client_id, client_secret: client_secret, scope: scope)
      https_client.instance_variable_set(:@token, 'test_token')
      allow(https_client).to receive(:ensure_token!).and_return(nil)

      stub_request(:get, 'https://api.example.com/test')
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 200, body: '{}')

      expect(Net::HTTP).to receive(:new).with('api.example.com', 443).and_call_original
      https_client.send(:get_json, '/test')
    end

    it 'disables SSL for HTTP URLs' do
      http_client = described_class.new(base_url: 'http://api.example.com', token_url: token_url, client_id: client_id, client_secret: client_secret, scope: scope)
      http_client.instance_variable_set(:@token, 'test_token')
      allow(http_client).to receive(:ensure_token!).and_return(nil)

      stub_request(:get, 'http://api.example.com/test')
        .with(headers: { 'Authorization' => 'Bearer test_token', 'Accept' => 'application/json' })
        .to_return(status: 200, body: '{}')

      expect(Net::HTTP).to receive(:new).with('api.example.com', 80).and_call_original
      http_client.send(:get_json, '/test')
    end
  end

  describe 'HttpError class' do
    it 'initializes with status and body' do
      error = TdxFeedbackGem::Client::HttpError.new('Test error', status: 500, body: 'Error body')
      expect(error.status).to eq(500)
      expect(error.body).to eq('Error body')
    end

    it 'provides default values' do
      error = TdxFeedbackGem::Client::HttpError.new('Test error', status: 0)
      expect(error.status).to eq(0)
      expect(error.body).to be_nil
    end
  end
end
