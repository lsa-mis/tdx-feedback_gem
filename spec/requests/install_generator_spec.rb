# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Install Generator', type: :request do
  let(:dummy_app_root) { Rails.root }

  before do
    # Clean up any existing files from previous tests
    FileUtils.rm_f(File.join(dummy_app_root, 'config', 'initializers', 'tdx_feedback_gem.rb'))
    FileUtils.rm_f(File.join(dummy_app_root, 'app', 'javascript', 'controllers', 'tdx_feedback_controller.js'))
    FileUtils.rm_f(File.join(dummy_app_root, 'app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss'))
    FileUtils.rm_f(File.join(dummy_app_root, 'app', 'assets', 'stylesheets', 'tdx_feedback_gem.css'))

    # Clean up migration files
    Dir.glob(File.join(dummy_app_root, 'db', 'migrate', '*_create_tdx_feedback_gem_feedbacks.rb')).each do |file|
      FileUtils.rm_f(file)
    end
  end

  after do
    # Clean up after tests
    FileUtils.rm_f(File.join(dummy_app_root, 'config', 'initializers', 'tdx_feedback_gem.rb'))
    FileUtils.rm_f(File.join(dummy_app_root, 'app', 'javascript', 'controllers', 'tdx_feedback_controller.js'))
    FileUtils.rm_f(File.join(dummy_app_root, 'app', 'assets', 'stylesheets', '_tdx_feedback_gem.scss'))
    FileUtils.rm_f(File.join(dummy_app_root, 'app', 'assets', 'stylesheets', 'tdx_feedback_gem.css'))

    Dir.glob(File.join(dummy_app_root, 'db', 'migrate', '*_create_tdx_feedback_gem_feedbacks.rb')).each do |file|
      FileUtils.rm_f(file)
    end
  end

  describe 'generator functionality' do
    it 'verifies generator files exist' do
      # Check that the generator template files exist
      migration_template = File.join(__dir__, '..', '..', 'lib', 'generators', 'tdx_feedback_gem', 'install', 'templates', 'migration.rb')
      expect(File.exist?(migration_template)).to be true

      initializer_template = File.join(__dir__, '..', '..', 'lib', 'generators', 'tdx_feedback_gem', 'install', 'templates', 'initializer.rb')
      expect(File.exist?(initializer_template)).to be true

      # Check that the generator class can be loaded
      expect { require 'generators/tdx_feedback_gem/install/install_generator' }.not_to raise_error

      # Check that the generator class exists
      expect(defined?(TdxFeedbackGem::Generators::InstallGenerator)).to be_truthy
    end

    it 'verifies migration template content' do
      migration_template = File.join(__dir__, '..', '..', 'lib', 'generators', 'tdx_feedback_gem', 'install', 'templates', 'migration.rb')
      migration_content = File.read(migration_template)

      expect(migration_content).to include('create_table :tdx_feedback_gem_feedbacks')
      expect(migration_content).to include('t.text :message')
      expect(migration_content).to include('t.text :context')
      expect(migration_content).to include('add_index :tdx_feedback_gem_feedbacks, :created_at')
    end

    it 'verifies initializer template content' do
      initializer_template = File.join(__dir__, '..', '..', 'lib', 'generators', 'tdx_feedback_gem', 'install', 'templates', 'initializer.rb')
      initializer_content = File.read(initializer_template)

      expect(initializer_content).to include('TdxFeedbackGem.configure')
    end
  end
end
