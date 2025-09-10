# lib/tdx_feedback_gem/engine.rb
# frozen_string_literal: true

module TdxFeedbackGem
  class Engine < ::Rails::Engine
    isolate_namespace TdxFeedbackGem

    # Configuration-driven behavior (see Configuration class for precedence rules)
    def self.auto_pin_importmap?
      TdxFeedbackGem.config.auto_pin_importmap
    end

    def self.runtime_scss_copy?
      TdxFeedbackGem.config.runtime_scss_copy
    end

    # Register generators
    generators do
      require "generators/tdx_feedback_gem/install/install_generator"
    end

    # Include the helper module in the main application
    initializer "tdx_feedback_gem.helpers" do |_app|
      ActiveSupport.on_load(:action_controller) do
        helper TdxFeedbackGem::ApplicationHelper
      end
    end

    # Make stylesheets available to host apps
    initializer "tdx_feedback_gem.assets" do |app|
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[tdx_feedback_gem.css]
      end

      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join("app", "assets", "stylesheets")
      end
    end

    # Ensure Stimulus controllers are available for importmap users
    initializer "tdx_feedback_gem.importmap", before: "importmap" do |app|
      if defined?(Importmap)
        app.config.importmap.paths << root.join("app/javascript")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end
    end

    # Auto-pin the Stimulus controller for Importmap users so the gem is truly "drop in".
    # This runs after the host app's importmap has been drawn so we can safely append
    # only if not already pinned. Can be disabled with TDX_FEEDBACK_GEM_AUTO_PIN=0.
    initializer "tdx_feedback_gem.auto_pin_controller", after: "importmap" do |app|
      next unless ::TdxFeedbackGem::Engine.auto_pin_importmap?
      next unless defined?(Importmap) && app.respond_to?(:importmap)
      begin
        # If the host already pinned controllers (e.g. pin_all_from ... under: "controllers")
        # then this individual pin is unnecessary. We check first to avoid duplicates.
        unless app.importmap.pinned?("controllers/tdx_feedback_controller")
          # Because we added the engine path to importmap.paths earlier, this logical path
            # will resolve either to the host app's controller (if they overrode it) or
            # the engine's copy.
          app.importmap.pin "controllers/tdx_feedback_controller", to: "controllers/tdx_feedback_controller.js", preload: true
        end
      rescue => e
        Rails.logger.debug("[tdx_feedback_gem] importmap auto-pin skipped: #{e.class}: #{e.message}")
      end
    end

    # Update the default title prefix to include the host app's name
    initializer "tdx_feedback_gem.application_name" do |_app|
      app_name = Rails.application.class.module_parent_name
      if app_name.present? && TdxFeedbackGem.config.title_prefix == "[Feedback]"
        TdxFeedbackGem.config.title_prefix = "[#{app_name} Feedback]"
      end
    end

    # Provide flexible asset inclusion for different scenarios (SCSS support)
    initializer "tdx_feedback_gem.flexible_assets" do |app|
      # Only copy SCSS partial dynamically if configuration allows (typically dev/test)
      if ::TdxFeedbackGem::Engine.runtime_scss_copy?
        app.config.to_prepare do
          if TdxFeedbackGem::Engine.host_app_uses_scss?(app)
            TdxFeedbackGem::Engine.provide_scss_version(app)
          end
        end
      end
    end

    class << self
      def host_app_uses_scss?(app)
        scss_files = Dir.glob(app.root.join("app", "assets", "stylesheets", "*.scss"))
        sass_files = Dir.glob(app.root.join("app", "assets", "stylesheets", "*.sass"))
        app_scss   = app.root.join("app", "assets", "stylesheets", "application.scss")
        app_sass   = app.root.join("app", "assets", "stylesheets", "application.sass")

        !scss_files.empty? || !sass_files.empty? || File.exist?(app_scss) || File.exist?(app_sass)
      end

      def provide_scss_version(app)
        css_source  = root.join("app", "assets", "stylesheets", "tdx_feedback_gem.css")
        scss_source = root.join("app", "assets", "stylesheets", "_tdx_feedback_gem.scss")
        scss_dest   = app.root.join("app", "assets", "stylesheets", "_tdx_feedback_gem.scss")

        unless File.exist?(scss_dest) && File.mtime(scss_dest) >= File.mtime(css_source)
          if File.exist?(scss_source)
            FileUtils.cp(scss_source, scss_dest)
          else
            css_content = File.read(css_source)
            File.write(scss_dest, css_content)
          end
        end
      end
    end
  end
end
