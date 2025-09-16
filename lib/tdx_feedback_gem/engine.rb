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
      require 'generators/tdx_feedback_gem/install/install_generator'
    end

    # Include the helper module in the main application (resilient to load issues)
    initializer 'tdx_feedback_gem.helpers' do |_app|
      begin
        ActiveSupport.on_load(:action_controller) do
          helper TdxFeedbackGem::ApplicationHelper
        end
      rescue => e
        Rails.logger.error("[tdx_feedback_gem] Failed to load helper: #{e.class}: #{e.message}") if defined?(Rails)
      end
    end

    # Make stylesheets available to host apps
    initializer 'tdx_feedback_gem.assets' do |app|
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[tdx_feedback_gem.css]
      end

      if app.config.respond_to?(:assets)
        app.config.assets.paths << root.join('app', 'assets', 'stylesheets')
      end
    end

    # Ensure Stimulus controllers are available for importmap users
    # Only append the JavaScript root if it contains a valid importmap.json file to avoid
    # pushing raw directories (which caused FrozenError in some host apps).
    initializer 'tdx_feedback_gem.importmap', before: 'importmap' do |app|
      next unless defined?(Importmap)

      js_path = root.join('app', 'javascript')
      importmap_file = js_path.join('importmap.json')
      if (defined?(Rails) && Rails.env.test?) || importmap_file.exist?
        # importmap-rails expects entries in config.importmap.paths to be FILES (JSON/RB), not directories
        unless app.config.importmap.paths.include?(importmap_file)
          app.config.importmap.paths << importmap_file
        end
        # cache sweepers can safely point at the directory for change detection
        unless app.config.importmap.cache_sweepers.include?(js_path)
          app.config.importmap.cache_sweepers << js_path
        end
      else
        Rails.logger.debug('[tdx_feedback_gem] importmap.json missing; skipping path registration') if defined?(Rails)
      end
    end

    # Auto-pin the Stimulus controller for Importmap users so the gem is truly "drop in".
    # This runs after the host app's importmap has been drawn so we can safely append
    # only if not already pinned. Can be disabled with TDX_FEEDBACK_GEM_AUTO_PIN=0.
    initializer 'tdx_feedback_gem.auto_pin_controller', after: 'importmap' do |app|
      next unless ::TdxFeedbackGem::Engine.auto_pin_importmap?
      next unless defined?(Importmap) && app.respond_to?(:importmap)
      begin
        controller_path = root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')
        unless controller_path.exist?
          Rails.logger.debug('[tdx_feedback_gem] Controller file not found, skipping auto-pin') if defined?(Rails)
          next
        end

        # Fallback: ensure engine JS path is available even if earlier initializer skipped
        js_path = root.join('app', 'javascript')
        importmap_file = js_path.join('importmap.json')
        if app.config.respond_to?(:importmap) && app.config.importmap.respond_to?(:paths)
          unless app.config.importmap.paths.include?(importmap_file)
            app.config.importmap.paths << importmap_file
            app.config.importmap.cache_sweepers << js_path if app.config.importmap.respond_to?(:cache_sweepers)
          end
        end

        unless app.importmap.respond_to?(:pinned?)
          # Provide a defensive pinned? method if missing (older or custom importmap setups)
          app.importmap.define_singleton_method(:pinned?) do |name|
            packages = instance_variable_get(:@packages) rescue {}
            packages.key?(name)
          end
        end

  # Force pin (idempotent in typical importmap implementations) to avoid false negatives in custom stubs/test envs
        begin
          app.importmap.pin 'controllers/tdx_feedback_controller', to: 'controllers/tdx_feedback_controller.js', preload: true
        rescue => pin_err
          Rails.logger.debug("[tdx_feedback_gem] pin attempt failed: #{pin_err.class}: #{pin_err.message}") if defined?(Rails)
        end
      rescue => e
        Rails.logger.debug("[tdx_feedback_gem] importmap auto-pin skipped: #{e.class}: #{e.message}") if defined?(Rails)
      end
    end

    # Late fallback in case earlier importmap initializers were skipped in certain test setups
    initializer 'tdx_feedback_gem.auto_pin_late', after: :finisher_hook do |app|
      next unless ::TdxFeedbackGem::Engine.auto_pin_importmap?
      next unless defined?(Importmap) && app.respond_to?(:importmap)
      begin
        unless app.importmap.respond_to?(:pinned?) && app.importmap.pinned?('controllers/tdx_feedback_controller')
          controller_path = root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')
            if controller_path.exist?
              app.importmap.pin 'controllers/tdx_feedback_controller', to: 'controllers/tdx_feedback_controller.js', preload: true
            end
        end
      rescue => e
        Rails.logger.debug("[tdx_feedback_gem] late auto-pin skipped: #{e.class}: #{e.message}") if defined?(Rails)
      end
    end

    # Update the default title prefix to include the host app's name
    initializer 'tdx_feedback_gem.application_name' do |_app|
      app_name = Rails.application.class.module_parent_name
      if app_name.present? && TdxFeedbackGem.config.title_prefix == '[Feedback]'
        TdxFeedbackGem.config.title_prefix = "[#{app_name} Feedback]"
      end
    end

    # Provide flexible asset inclusion for different scenarios (SCSS support)
    initializer 'tdx_feedback_gem.flexible_assets' do |app|
      # Only copy SCSS partial dynamically if configuration allows (typically dev/test)
      if ::TdxFeedbackGem::Engine.runtime_scss_copy?
        app.config.to_prepare do
          if TdxFeedbackGem::Engine.host_app_uses_scss?(app)
            TdxFeedbackGem::Engine.provide_scss_version(app)
          end
        end
      end
    end

    # Re-resolve credentials after Rails initialization to ensure proper reading
    initializer 'tdx_feedback_gem.resolve_credentials', after: :finisher_hook do |_app|
      if TdxFeedbackGem.respond_to?(:config) && TdxFeedbackGem.config.respond_to?(:resolve_credentials_after_initialization!)
        begin
          TdxFeedbackGem.config.resolve_credentials_after_initialization!
        rescue => e
          Rails.logger.debug("[tdx_feedback_gem] credentials resolution failed: #{e.class}: #{e.message}") if defined?(Rails)
        end
      end
    end

    # Validate configuration and emit warnings after initial setup
    initializer 'tdx_feedback_gem.validate_configuration', after: 'tdx_feedback_gem.application_name' do |_app|
      if TdxFeedbackGem.respond_to?(:config) && TdxFeedbackGem.config.respond_to?(:validate_configuration!)
        begin
          TdxFeedbackGem.config.validate_configuration!
        rescue => e
          Rails.logger.debug("[tdx_feedback_gem] configuration validation failed: #{e.class}: #{e.message}") if defined?(Rails)
        end
      end
    end

    class << self
      def host_app_uses_scss?(app)
        scss_files = Dir.glob(app.root.join('app', 'assets', 'stylesheets', '*.scss'))
        sass_files = Dir.glob(app.root.join('app', 'assets', 'stylesheets', '*.sass'))
        app_scss   = app.root.join('app', 'assets', 'stylesheets', 'application.scss')
        app_sass   = app.root.join('app', 'assets', 'stylesheets', 'application.sass')

        !scss_files.empty? || !sass_files.empty? || File.exist?(app_scss) || File.exist?(app_sass)
      end

      def provide_scss_version(app)
        css_source  = root.join('app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')
        scss_source = root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')
        scss_dest   = app.root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')

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
