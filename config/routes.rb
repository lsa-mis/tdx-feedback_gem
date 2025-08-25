# frozen_string_literal: true

TdxFeedbackGem::Engine.routes.draw do
  resources :feedbacks, only: %i[new create], defaults: { format: :json }
end
