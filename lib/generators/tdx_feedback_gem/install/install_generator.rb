# frozen_string_literal: true

require 'rails/generators'
require 'fileutils'

module TdxFeedbackGem
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Installs TdxFeedbackGem by creating migration, initializer, assets, and optional importmap pins.'

      def copy_migration
        timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
        create_file "db/migrate/#{timestamp}_create_tdx_feedback_gem_feedbacks.rb",
                    File.read(File.join(self.class.source_root, 'migration.rb'))
      end

      def create_initializer
        template 'initializer.rb', 'config/initializers/tdx_feedback_gem.rb'
      end

      def include_javascript
        # Copy the Stimulus controller to the host app
        # Use the engine's root path for reliability
        controller_source = TdxFeedbackGem::Engine.root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')
        controller_dest = Rails.root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')

        # Create controllers directory if it doesn't exist
        FileUtils.mkdir_p(controller_dest.dirname) unless Dir.exist?(controller_dest.dirname)

        # Copy controller file
        FileUtils.cp(controller_source, controller_dest) unless File.exist?(controller_dest)

        # Update application.js to include the controller
        update_application_js
      end

      def include_css
        # Determine if the host app uses SCSS or CSS
        if host_app_uses_scss?
          include_scss_styles
        else
          include_css_styles
        end
      end

      def add_routes
        return if File.read('config/routes.rb').include?('TdxFeedbackGem::Engine')
        route "mount TdxFeedbackGem::Engine => '/tdx_feedback_gem'"
      end

      def add_importmap_pin
        return unless defined?(Importmap)
        importmap_rb = 'config/importmap.rb'
        return unless File.exist?(importmap_rb)
        content = File.read(importmap_rb)
        pin_line = "pin_all_from 'tdx_feedback_gem/app/javascript/controllers', under: 'controllers'"
        unless content.include?(pin_line)
          append_to_file importmap_rb do
            "\n# TDX Feedback Gem controllers\n#{pin_line}\n"
          end
        end
      end

      def show_instructions
        say "\nTDX Feedback Gem installed successfully!", :green
        say "\nNext steps:", :yellow
        say "1. rails db:migrate"
        say "2. Review config/initializers/tdx_feedback_gem.rb"
        say "3. Configure TDX settings via Rails credentials or environment variables:"
        say "   - Credentials: tdx.development.enable_ticket_creation: 'true'"
        say "   - Environment: TDX_ENABLE_TICKET_CREATION=true"
        say "   - Account ID: tdx.development.account_id: 1 or TDX_ACCOUNT_ID=1"
        say "4. (Optional) Customize feedback trigger in your layout footer: <%= feedback_system(trigger: :link, text: 'Feedback') %>"
        say "5. Restart your server"
        say "6. Verify modal loads and submissions create tickets (if enabled)."
        say "\nNew features:", :cyan
        say "• Enhanced credentials resolution - settings properly read from credentials/ENV"
        say "• JSON payload logging - detailed TDX API request logging for debugging"
        say "• Account ID support - configure via credentials or environment variables"
      end

      private

      def host_app_uses_scss?
        # Check if the host app has SCSS files
        scss_files = Dir.glob(Rails.root.join('app', 'assets', 'stylesheets', '*.scss'))
        sass_files = Dir.glob(Rails.root.join('app', 'assets', 'stylesheets', '*.sass'))

        # Also check for application.scss or application.sass
        app_scss = Rails.root.join('app', 'assets', 'stylesheets', 'application.scss')
        app_sass = Rails.root.join('app', 'assets', 'stylesheets', 'application.sass')

        !scss_files.empty? || !sass_files.empty? || File.exist?(app_scss) || File.exist?(app_sass)
      end

      def include_scss_styles
        # Use the SCSS version if available, otherwise convert CSS
        scss_source = TdxFeedbackGem::Engine.root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')
        css_source = TdxFeedbackGem::Engine.root.join('app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')
        scss_dest = Rails.root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')

        # Use SCSS version if it exists, otherwise convert CSS
        if File.exist?(scss_source)
          FileUtils.cp(scss_source, scss_dest) unless File.exist?(scss_dest)
        else
          # Fallback: convert CSS to SCSS (simple conversion - just change extension and add partial prefix)
          css_content = File.read(css_source)
          File.write(scss_dest, css_content) unless File.exist?(scss_dest)
        end

        # Update application.scss to include the stylesheet
        update_application_scss
      end

      def include_css_styles
        # Copy the CSS file to the host app
        css_source = TdxFeedbackGem::Engine.root.join('app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')
        css_dest = Rails.root.join('app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')

        # Copy CSS file
        FileUtils.cp(css_source, css_dest) unless File.exist?(css_dest)

        # Update application.css to include the stylesheet
        update_application_css
      end

      def update_application_js
        app_js_path = Rails.root.join('app', 'javascript', 'application.js')

        if File.exist?(app_js_path)
          content = File.read(app_js_path)

          # Check if the controller is already imported
          unless content.include?('tdx_feedback_controller')
            # Add import statement
            import_line = "import './controllers/tdx_feedback_controller'\n"

            # Find the best place to insert (after other imports)
            if content.include?('import')
              # Insert after the last import statement
              lines = content.lines
              last_import_index = lines.rindex { |line| line.strip.start_with?('import') }

              if last_import_index
                lines.insert(last_import_index + 1, import_line)
                File.write(app_js_path, lines.join)
              else
                # Fallback: add at the beginning
                File.write(app_js_path, import_line + content)
              end
            else
              # No imports found, add at the beginning
              File.write(app_js_path, import_line + content)
            end
          end
        end
      end

      def update_application_css
        app_css_path = Rails.root.join('app', 'assets', 'stylesheets', 'application.css')

        if File.exist?(app_css_path)
          content = File.read(app_css_path)

          # Check if the stylesheet is already included
          unless content.include?('tdx_feedback_gem')
            # Add require statement
            require_line = " *= require tdx_feedback_gem\n"

            # Find the best place to insert (after other requires)
            if content.include?('require')
              # Insert after the last require statement
              lines = content.lines
              last_require_index = lines.rindex { |line| line.strip.start_with?('*=') && line.include?('require') }

              if last_require_index
                lines.insert(last_require_index + 1, require_line)
                File.write(app_css_path, lines.join)
              else
                # Fallback: add at the end
                File.write(app_css_path, content + require_line)
              end
            else
              # No requires found, add at the end
              File.write(app_css_path, content + require_line)
            end
          end
        end
      end

      def update_application_scss
        # Try to find the main SCSS file
        possible_files = [
          Rails.root.join('app', 'assets', 'stylesheets', 'application.scss'),
          Rails.root.join('app', 'assets', 'stylesheets', 'application.sass'),
          Rails.root.join('app', 'assets', 'stylesheets', 'main.scss'),
          Rails.root.join('app', 'assets', 'stylesheets', 'main.sass')
        ]

        app_scss_path = possible_files.find { |path| File.exist?(path) }

        if app_scss_path
          content = File.read(app_scss_path)

          # Check if the stylesheet is already included
          unless content.include?('tdx_feedback_gem')
            # Add import statement for SCSS
            import_line = "@import 'tdx_feedback_gem';\n"

            # Find the best place to insert (after other imports)
            if content.include?('@import')
              # Insert after the last import statement
              lines = content.lines
              last_import_index = lines.rindex { |line| line.strip.start_with?('@import') }

              if last_import_index
                lines.insert(last_import_index + 1, import_line)
                File.write(app_scss_path, lines.join)
              else
                # Fallback: add at the end
                File.write(app_scss_path, content + import_line)
              end
            else
              # No imports found, add at the end
              File.write(app_scss_path, content + import_line)
            end
          end
        else
          # No SCSS file found, create a new one
          app_scss_path = Rails.root.join('app', 'assets', 'stylesheets', 'application.scss')
          content = "@import 'tdx_feedback_gem';\n"
          File.write(app_scss_path, content)
        end
      end
    end
  end
end
