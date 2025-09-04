# frozen_string_literal: true

require 'rails/generators'
require 'fileutils'

module TdxFeedbackGem
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Installs TdxFeedbackGem by creating migration, initializer, and including assets.'

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

      def show_instructions
        puts "\n🎉 TdxFeedbackGem has been successfully installed!"
        puts "\n📋 Next steps:"
        puts "1. Run 'rails db:migrate' to create the feedbacks table"
        puts "2. Add the engine to your host app routes (recommended mount path shown):"
        puts "   mount TdxFeedbackGem::Engine => '/tdx_feedback_gem'"
        puts "3. Recompile your assets:"
        puts "   bundle exec rake assets:clobber && bundle exec rake dartsass:build"
        puts "   bundle exec rake assets:precompile"
        puts "4. Edit config/initializers/tdx_feedback_gem.rb"
        puts "5. Restart your Rails server"
        puts "6. Use the helper methods in your views:"
        puts "   - <%= feedback_system(trigger: :link, text: 'Feedback', class: 'tdx-feedback-footer-link') %>"
        puts "   - <%= feedback_button('Send Feedback') %>"
        puts "   - <%= feedback_system(trigger: :button, text: 'Send Feedback') %>"
        puts "\n📚 For more information, check the documentation at:"
        puts "   https://github.com/your-username/tdx_feedback_gem"
        puts "\n✨ The gem is now ready to use!"
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
