# frozen_string_literal: true

module TdxFeedbackGem
  class Engine < ::Rails::Engine
    isolate_namespace TdxFeedbackGem

    # Include the helper module in the main application
    initializer 'tdx_feedback_gem.helpers' do |app|
      app.config.to_prepare do
        if defined?(ApplicationController)
          ApplicationController.helper TdxFeedbackGem::ApplicationHelper
        end
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

    # Automatically include the Rails application name in the title prefix
    initializer 'tdx_feedback_gem.application_name' do |app|
      # Get the Rails application module name (e.g., "MyApp" from "MyApp::Application")
      app_name = Rails.application.class.module_parent_name

      # Update the title_prefix to include the application name
      if app_name.present? && TdxFeedbackGem.config.title_prefix == '[Feedback]'
        TdxFeedbackGem.config.title_prefix = "[#{app_name} Feedback]"
      end
    end
  end
end
