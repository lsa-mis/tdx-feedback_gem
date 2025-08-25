# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TdxFeedbackGem::FeedbacksController, type: :controller do
  let(:valid_params) { { feedback: { message: 'Test feedback', context: 'Test context' } } }
  let(:invalid_params) { { feedback: { message: '', context: 'Test context' } } }

  before do
    TdxFeedbackGem.configure do |c|
      c.require_authentication = false
      c.enable_ticket_creation = false
    end

    # Set up routes to match the controller's namespace structure
    routes.draw do
      namespace :tdx_feedback_gem do
        resources :feedbacks, only: %i[new create], defaults: { format: :json }
      end
    end
  end

  after do
    TdxFeedbackGem.configure do |c|
      c.require_authentication = false
      c.enable_ticket_creation = false
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new, format: :json
      expect(response).to have_http_status(:ok)
    end

    it 'returns JSON with HTML partial' do
      get :new, format: :json
      json_response = JSON.parse(response.body)
      expect(json_response).to have_key('html')
    end

    it 'initializes a new feedback object' do
      get :new, format: :json
      expect(assigns(:feedback)).to be_a(TdxFeedbackGem::Feedback)
      expect(assigns(:feedback)).to be_new_record
    end

    it 'skips forgery protection' do
      expect(controller.class.skip_forgery_protection_actions).to include(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      context 'when ticket creation is disabled' do
        before do
          TdxFeedbackGem.configure { |c| c.enable_ticket_creation = false }
        end

        it 'creates a new feedback record' do
          expect {
            post :create, params: valid_params, format: :json
          }.to change(TdxFeedbackGem::Feedback, :count).by(1)
        end

        it 'returns success response' do
          post :create, params: valid_params, format: :json
          expect(response).to have_http_status(:created)
        end

        it 'returns success JSON with feedback id' do
          post :create, params: valid_params, format: :json
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response['feedback_id']).to be_present
          expect(json_response['ticket_id']).to be_nil
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

        it 'creates a new feedback record' do
          expect {
            post :create, params: valid_params, format: :json
          }.to change(TdxFeedbackGem::Feedback, :count).by(1)
        end

        it 'creates a ticket via TicketCreator' do
          post :create, params: valid_params, format: :json
          expect(ticket_creator).to have_received(:call).with(instance_of(TdxFeedbackGem::Feedback), requestor_email: 'test@example.com')
        end

        it 'returns success response with ticket id' do
          post :create, params: valid_params, format: :json
          json_response = JSON.parse(response.body)
          expect(json_response['success']).to be true
          expect(json_response['ticket_id']).to eq('123')
        end

        context 'when ticket creation fails' do
          let(:result) { instance_double(TdxFeedbackGem::TicketCreator::Result, success?: false, error: 'API Error') }

          it 'still creates the feedback record' do
            expect {
              post :create, params: valid_params, format: :json
            }.to change(TdxFeedbackGem::Feedback, :count).by(1)
          end

          it 'returns success response with failure message' do
            post :create, params: valid_params, format: :json
            json_response = JSON.parse(response.body)
            expect(json_response['success']).to be true
            expect(json_response['message']).to include('Ticket creation failed')
          end
        end
      end
    end

    context 'with invalid parameters' do
      it 'does not create a feedback record' do
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(TdxFeedbackGem::Feedback, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error JSON with validation errors' do
        post :create, params: invalid_params, format: :json
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to include("Message can't be blank")
      end
    end

    it 'skips forgery protection in test environment' do
      # In test environment, create action should skip forgery protection
      expect(controller.class.skip_forgery_protection_actions).to include(:create)
    end
  end

  describe 'authentication' do
    context 'when authentication is required' do
      before do
        TdxFeedbackGem.configure { |c| c.require_authentication = true }
      end

      context 'when user is authenticated' do
        before do
          allow(controller).to receive(:current_user).and_return(double('User'))
        end

        it 'allows access to new action' do
          get :new, format: :json
          expect(response).to have_http_status(:ok)
        end

        it 'allows access to create action' do
          post :create, params: { feedback: { message: 'Test' } }, format: :json
          expect(response).to have_http_status(:created)
        end
      end

      context 'when user is not authenticated' do
        before do
          allow(controller).to receive(:current_user).and_return(nil)
        end

        it 'returns unauthorized for new action' do
          get :new, format: :json
          expect(response).to have_http_status(:unauthorized)
        end

        it 'returns unauthorized for create action' do
          post :create, params: { feedback: { message: 'Test' } }, format: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when authentication is not required' do
      before do
        TdxFeedbackGem.configure { |c| c.require_authentication = false }
      end

      it 'allows access to new action' do
        get :new, format: :json
        expect(response).to have_http_status(:ok)
      end

      it 'allows access to create action' do
        post :create, params: { feedback: { message: 'Test' } }, format: :json
        expect(response).to have_http_status(:created)
      end
    end
  end

  describe 'CSRF protection' do
    it 'skips forgery protection for JSON requests' do
      # The controller is configured to skip forgery protection for create action in test environment
      expect(controller.class.skip_forgery_protection_actions).to include(:create)
    end
  end
end
