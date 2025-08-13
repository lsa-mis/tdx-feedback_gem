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
      c.status_id = 77
      c.source_id = 8
      c.service_id = 67
      c.responsible_group_id = 631
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

      def create_ticket(app_id:, payload: {}, params: {})
        @last_app_id = app_id
        @last_payload = payload.merge('__params__' => params)
        { 'ID' => 12_345 }
      end
    end.new
  end

  it 'builds a payload and returns ticket id' do
    feedback = TdxFeedbackGem::Feedback.create!(message: 'Hello world', context: 'ctx')
    creator = described_class.new(config: config, client: stub_client)
    result = creator.call(feedback)
    expect(result.success?).to be true
    expect(result.ticket_id).to eq(12_345)
    expect(stub_client.last_app_id).to eq(31)
    expect(stub_client.last_payload['Title']).to start_with('[Feedback]')
    expect(stub_client.last_payload['RequestorEmail']).to eq('noreply@example.com')
  end
end
