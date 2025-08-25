# frozen_string_literal: true

module TdxFeedbackGem
  class Engine < ::Rails::Engine
    isolate_namespace TdxFeedbackGem

    # Include the helper module in the main application
    initializer 'tdx_feedback_gem.helpers' do |app|
      app.config.to_prepare do
        ApplicationController.helper TdxFeedbackGem::ApplicationHelper
      end
    end

    initializer 'tdx_feedback_gem.assets' do |app|
      # Precompile engine styles for host apps when Sprockets is available
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[tdx_feedback_gem.css]
      end
    end

    # Ensure Stimulus controllers are available
    initializer 'tdx_feedback_gem.stimulus' do |app|
      # Copy Stimulus controller to host app's controllers directory
      app.config.to_prepare do
        if defined?(Stimulus)
          # The controller will be automatically loaded by Stimulus
          # from app/javascript/controllers/tdx_feedback_controller.js
        end
      end
    end
  end
end
