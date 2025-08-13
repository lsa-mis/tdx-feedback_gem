# frozen_string_literal: true

require 'rails_helper'
require 'capybara/rspec'

RSpec.describe 'Feedback flow', type: :request do
  include Capybara::DSL

  it 'shows the feedback form and submits successfully' do
    # Visit the form (simulating host app mount at /feedback)
    get '/feedback'
    expect(response).to have_http_status(:ok)

    # Submit the form
    post '/feedback/feedbacks', params: { feedback: { message: 'Great job', context: 'from test' } }

    # Should redirect to host app root and set a flash notice
    expect(response).to have_http_status(:found)
    follow_redirect! # to /
    follow_redirect! while response.redirect?
    expect(response.body).to include('Thank you for your feedback')
  end
end
