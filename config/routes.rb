# frozen_string_literal: true

TdxFeedbackGem::Engine.routes.draw do
  root to: 'feedbacks#new'
  resources :feedbacks, only: %i[new create]
end
