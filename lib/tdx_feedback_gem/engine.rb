# frozen_string_literal: true

require 'fileutils'

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

      # Include CSS in host app's asset pipeline
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
      end
    end

    # Ensure Stimulus controllers are available
    initializer 'tdx_feedback_gem.stimulus' do |app|
      app.config.to_prepare do
        if defined?(Stimulus)
          # Copy Stimulus controller to host app's controllers directory
          # This ensures the controller is available without manual copying
          controller_source = root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')
          controller_dest = app.root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')

          # Create controllers directory if it doesn't exist
          FileUtils.mkdir_p(controller_dest.dirname) unless Dir.exist?(controller_dest.dirname)

          # Copy controller file if it doesn't exist or is older
          unless File.exist?(controller_dest) && File.mtime(controller_dest) >= File.mtime(controller_source)
            FileUtils.cp(controller_source, controller_dest)
          end
        end
      end
    end

    # Include JavaScript in host app's asset pipeline
    initializer 'tdx_feedback_gem.javascript' do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join('app', 'javascript')
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

    # Provide flexible asset inclusion for different scenarios
    initializer 'tdx_feedback_gem.flexible_assets' do |app|
      app.config.to_prepare do
        # Check if we need to provide SCSS version for SCSS-based apps
        if TdxFeedbackGem::Engine.host_app_uses_scss?(app)
          TdxFeedbackGem::Engine.provide_scss_version(app)
        end
      end
    end

    class << self
      def host_app_uses_scss?(app)
        # Check if the host app has SCSS files
        scss_files = Dir.glob(app.root.join('app', 'assets', 'stylesheets', '*.scss'))
        sass_files = Dir.glob(app.root.join('app', 'assets', 'stylesheets', '*.sass'))

        # Also check for application.scss or application.sass
        app_scss = app.root.join('app', 'assets', 'stylesheets', 'application.scss')
        app_sass = app.root.join('app', 'assets', 'stylesheets', 'application.sass')

        !scss_files.empty? || !sass_files.empty? || File.exist?(app_scss) || File.exist?(app_sass)
      end

      def provide_scss_version(app)
        # If the host app uses SCSS, provide a SCSS version of our styles
        css_source = root.join('app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')
        scss_source = root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')
        scss_dest = app.root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')

        # Only copy if it doesn't exist or is older
        unless File.exist?(scss_dest) && File.mtime(scss_dest) >= File.mtime(css_source)
          # Use SCSS version if it exists, otherwise convert CSS
          if File.exist?(scss_source)
            FileUtils.cp(scss_source, scss_dest)
          else
            # Fallback: convert CSS to SCSS (simple conversion - just change extension and add partial prefix)
            css_content = File.read(css_source)
            File.write(scss_dest, css_content)
          end
        end
      end
    end
  end
end
