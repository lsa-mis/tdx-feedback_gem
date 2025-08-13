# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/feedback')
  mount TdxFeedbackGem::Engine => '/feedback'
end
