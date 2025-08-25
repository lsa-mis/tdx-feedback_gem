# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Feedback flow', type: :request do
  before do
    TdxFeedbackGem.configure do |c|
      c.require_authentication = false
      c.enable_ticket_creation = false
    end
  end

  after do
    TdxFeedbackGem.configure do |c|
      c.require_authentication = false
      c.enable_ticket_creation = false
    end
  end

  describe 'GET /feedback/feedbacks/new' do
    it 'shows the feedback form successfully' do


      get '/feedback/feedbacks/new'
      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON response' do
      get '/feedback/feedbacks/new'
      expect(response.content_type).to include('application/json')
    end

    it 'initializes a new feedback object' do
      get '/feedback/feedbacks/new'
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('html')
    end
  end

  describe 'POST /feedback/feedbacks' do
    let(:valid_params) { { feedback: { message: 'Great job on the new feature!', context: 'User interface improvements' } } }
    let(:invalid_params) { { feedback: { message: '', context: 'User interface improvements' } } }

    context 'with valid parameters' do
      it 'creates a new feedback record' do
        expect {
          post '/feedback/feedbacks', params: valid_params
        }.to change(TdxFeedbackGem::Feedback, :count).by(1)
      end

      it 'returns success response' do
        post '/feedback/feedbacks', params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns success JSON' do
        post '/feedback/feedbacks', params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['feedback_id']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'does not create a feedback record' do
        expect {
          post '/feedback/feedbacks', params: invalid_params
        }.not_to change(TdxFeedbackGem::Feedback, :count)
      end

      it 'returns unprocessable entity status' do
        post '/feedback/feedbacks', params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error JSON' do
        post '/feedback/feedbacks', params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to include("Message can't be blank")
      end
    end

    context 'when ticket creation is enabled' do
      let(:ticket_creator) { instance_double(TdxFeedbackGem::TicketCreator) }
      let(:result) { instance_double(TdxFeedbackGem::TicketCreator::Result, success?: true, ticket_id: '123') }

      before do
        TdxFeedbackGem.configure { |c| c.enable_ticket_creation = true }
        allow(TdxFeedbackGem::TicketCreator).to receive(:new).and_return(ticket_creator)
        allow(ticket_creator).to receive(:call).and_return(result)
      end

      it 'creates a ticket via TicketCreator' do
        post '/feedback/feedbacks', params: valid_params
        expect(ticket_creator).to have_received(:call).with(instance_of(TdxFeedbackGem::Feedback), requestor_email: nil)
      end

      it 'returns success response with ticket id' do
        post '/feedback/feedbacks', params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['ticket_id']).to eq('123')
      end

      context 'when ticket creation fails' do
        let(:result) { instance_double(TdxFeedbackGem::TicketCreator::Result, success?: false, error: 'API Error') }

        it 'still creates the feedback record' do
          expect {
            post '/feedback/feedbacks', params: valid_params
          }.to change(TdxFeedbackGem::Feedback, :count).by(1)
        end

        it 'returns success response with failure message' do
          post '/feedback/feedbacks', params: valid_params
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response['message']).to include('Ticket creation failed')
        end
      end
    end

    context 'with malformed parameters' do
      it 'handles missing feedback parameter' do
        post '/feedback/feedbacks', params: {}
        expect(response).to have_http_status(:bad_request)
      end

      it 'handles nil feedback parameter' do
        post '/feedback/feedbacks', params: { feedback: nil }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe 'authentication flow' do
    context 'when authentication is required' do
      before do
        TdxFeedbackGem.configure { |c| c.require_authentication = true }
      end

      it 'returns unauthorized for new action without authentication' do
        get '/feedback/feedbacks/new'
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns unauthorized for create action without authentication' do
        post '/feedback/feedbacks', params: { feedback: { message: 'Test' } }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authentication is not required' do
      before do
        TdxFeedbackGem.configure { |c| c.require_authentication = false }
      end

      it 'allows access to new action' do
        get '/feedback/feedbacks/new'
        expect(response).to have_http_status(:ok)
      end

      it 'allows access to create action' do
        post '/feedback/feedbacks', params: { feedback: { message: 'Test' } }
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'CSRF protection' do
    it 'skips forgery protection for new action' do
      get '/feedback/feedbacks/new'
      expect(response).to have_http_status(:ok)
    end

    it 'skips forgery protection for create action' do
      post '/feedback/feedbacks', params: { feedback: { message: 'Test' } }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'complete feedback workflow' do
    it 'allows a user to submit feedback and receive confirmation' do
      # First, get the feedback form
      get '/feedback/feedbacks/new'
      expect(response).to have_http_status(:ok)

      # Then submit feedback
      post '/feedback/feedbacks', params: { feedback: { message: 'Great work!', context: 'Testing' } }
      expect(response).to have_http_status(:created)

      # Verify the feedback was created
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['feedback_id']).to be_present
    end
  end

  describe 'error handling' do
    it 'handles invalid JSON gracefully' do
      post '/feedback/feedbacks',
           params: 'invalid json',
           headers: { 'CONTENT_TYPE' => 'application/json' }
      expect(response).to have_http_status(:bad_request)
    end

    it 'handles missing parameters gracefully' do
      post '/feedback/feedbacks'
      expect(response).to have_http_status(:bad_request)
    end
  end
end
