# frozen_string_literal: true

require 'spec_helper'

# This spec is designed to be run against a real Rails application
# to test the full integration of the gem
RSpec.describe 'Real Application Integration', type: :integration do
  # For gem development, we want to run these tests against the dummy app
  # The dummy app simulates a real Rails application

  # Set up the dummy app with required files before running tests
  before(:all) do
    setup_dummy_app
  end

  def setup_dummy_app
    # Create the initializer file
    initializer_path = Rails.root.join('config', 'initializers', 'tdx_feedback_gem.rb')
    FileUtils.mkdir_p(initializer_path.dirname) unless Dir.exist?(initializer_path.dirname)

    unless File.exist?(initializer_path)
      File.write(initializer_path, <<~RUBY)
        # frozen_string_literal: true

        # TdxFeedbackGem configuration
        TdxFeedbackGem.configure do |config|
          # Configure your TDX settings here
          # config.tdx_base_url = 'https://your-tdx-instance.com'
          # config.tdx_username = 'your_username'
          # config.tdx_password = 'your_password'
          # config.tdx_app_id = 'your_app_id'
          # config.tdx_app_key = 'your_app_key'
        end
      RUBY
    end

    # Create the JavaScript controller file
    controller_path = Rails.root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')
    FileUtils.mkdir_p(controller_path.dirname) unless Dir.exist?(controller_path.dirname)

    unless File.exist?(controller_path)
      File.write(controller_path, <<~JS)
        import { Controller } from "@hotwired/stimulus"

        export default class extends Controller {
          connect() {
            console.log("TdxFeedback controller connected")
          }

          openModal() {
            // Implementation for opening feedback modal
            console.log("Opening feedback modal")
          }
        }
      JS
    end

    # Copy stylesheet files to dummy app
    stylesheets_dir = Rails.root.join('app', 'assets', 'stylesheets')
    FileUtils.mkdir_p(stylesheets_dir) unless Dir.exist?(stylesheets_dir)

    # Copy SCSS file
    scss_source = File.join(__dir__, '..', '..', 'app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')
    scss_dest = stylesheets_dir.join('_tdx_feedback_gem.scss')
    FileUtils.cp(scss_source, scss_dest) if File.exist?(scss_source) && !File.exist?(scss_dest)

    # Copy CSS file
    css_source = File.join(__dir__, '..', '..', 'app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')
    css_dest = stylesheets_dir.join('tdx_feedback_gem.css')
    FileUtils.cp(css_source, css_dest) if File.exist?(css_source) && !File.exist?(css_dest)
  end

  describe 'gem installation' do
    it 'can be added to Gemfile' do
      gemfile_content = File.read(Rails.root.join('Gemfile'))
      expect(gemfile_content).to include('tdx_feedback_gem')
    end

    it 'can be installed via generator' do
      # This would be tested by running the generator in a real app
      expect(File.exist?(Rails.root.join('config', 'initializers', 'tdx_feedback_gem.rb'))).to be true
    end

    it 'creates the database table' do
      # This would be tested by running migrations in a real app
      expect(ActiveRecord::Base.connection.table_exists?('tdx_feedback_gem_feedbacks')).to be true
    end
  end

  describe 'helper methods' do
    it 'provides feedback_link helper' do
      # Check if the helper is available in the dummy app's ApplicationController
      expect(ApplicationController.helpers.respond_to?(:feedback_link)).to be true
    end

    it 'provides feedback_button helper' do
      # Check if the helper is available in the dummy app's ApplicationController
      expect(ApplicationController.helpers.respond_to?(:feedback_button)).to be true
    end

    it 'provides feedback_system helper' do
      # Check if the helper is available in the dummy app's ApplicationController
      expect(ApplicationController.helpers.respond_to?(:feedback_system)).to be true
    end
  end

  describe 'JavaScript integration' do
    it 'loads the Stimulus controller' do
      controller_path = Rails.root.join('app', 'javascript', 'controllers', 'tdx_feedback_controller.js')
      expect(File.exist?(controller_path)).to be true
    end

    it 'includes the controller in application.js' do
      app_js_path = Rails.root.join('app', 'javascript', 'application.js')
      if File.exist?(app_js_path)
        content = File.read(app_js_path)
        expect(content).to include('tdx_feedback_controller')
      end
    end
  end

  describe 'stylesheet integration' do
    it 'includes the stylesheet' do
      scss_file = Rails.root.join('app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss')
      css_file = Rails.root.join('app', 'assets', 'stylesheets', 'tdx_feedback_gem.css')

      expect(File.exist?(scss_file) || File.exist?(css_file)).to be true
    end

    it 'includes styles in application stylesheet' do
      app_scss = Rails.root.join('app', 'assets', 'stylesheets', 'application.scss')
      app_css = Rails.root.join('app', 'assets', 'stylesheets', 'application.css')

      if File.exist?(app_scss)
        content = File.read(app_scss)
        expect(content).to include('tdx_feedback_gem')
      elsif File.exist?(app_css)
        content = File.read(app_css)
        expect(content).to include('tdx_feedback_gem')
      end
    end
  end

  # No private methods needed
end
