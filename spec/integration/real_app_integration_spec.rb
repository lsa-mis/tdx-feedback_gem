# frozen_string_literal: true

require 'rails_helper'

# This spec is designed to be run against a real Rails application
# to test the full integration of the gem
RSpec.describe 'Real Application Integration', type: :integration do
  # Skip these tests unless we're in a real application context
  before do
    # Comment out this skip for gem development - tests will run against dummy app
    # skip "This test requires a real Rails application context" unless real_app_context?
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
      expect(ActionController::Base.helpers.respond_to?(:feedback_link)).to be true
    end

    it 'provides feedback_button helper' do
      expect(ActionController::Base.helpers.respond_to?(:feedback_button)).to be true
    end

    it 'provides feedback_system helper' do
      expect(ActionController::Base.helpers.respond_to?(:feedback_system)).to be true
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

  private

  def real_app_context?
    # Check if we're in a real Rails app (not the dummy app)
    # For gem development, allow tests to run against dummy app
    true
  end
end
