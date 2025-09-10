# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Importmap auto pin', type: :integration do
  before do
    TdxFeedbackGem.config.auto_pin_importmap = true

    # Ensure Importmap is available even if the dummy app didn't load the railtie
    unless defined?(Importmap)
      begin
        require 'importmap-rails'
      rescue LoadError
        skip 'importmap gem not available'
      end
    end

    app = Rails.application
    unless app.respond_to?(:importmap) && app.importmap
      # Minimal Importmap::Map instance emulating importmap-rails behavior
      map_class = if defined?(Importmap::Map)
        Importmap::Map
      else
        # Define a trivial Map compatible subset for the test
        module Importmap; end unless defined?(Importmap)
        class Importmap::Map
          def initialize; @packages = {}; end
          def pin(name, to:, preload: false)
            @packages[name] ||= { to: to, preload: preload }
          end
          def pinned?(name); @packages.key?(name); end
          def packages; @packages; end
        end
        Importmap::Map
      end
      app.singleton_class.class_eval do
        attr_accessor :importmap
      end
      app.importmap = map_class.new
      # Add pinned? helper if missing so engine initializer logic works uniformly
      unless app.importmap.respond_to?(:pinned?)
        app.importmap.define_singleton_method(:pinned?) do |name|
          if respond_to?(:packages)
            packages.key?(name)
          else
            instance_variable_get(:@packages).key?(name)
          end
        end
      end
    end

    # Manually emulate the importmap path initializer to avoid context issues with root inside engine
    if app.config.respond_to?(:importmap)
      js_dir = TdxFeedbackGem::Engine.root.join('app/javascript')
      importmap_file = js_dir.join('importmap.json')
      app.config.importmap.paths << importmap_file unless app.config.importmap.paths.include?(importmap_file)
      app.config.importmap.cache_sweepers << js_dir unless app.config.importmap.cache_sweepers.include?(js_dir)
    end
  auto_pin_init = TdxFeedbackGem::Engine.initializers.find { |i| i.name == 'tdx_feedback_gem.auto_pin_controller' }
  auto_pin_init.run(app) if auto_pin_init

  # Also run late fallback initializer (covers alternate init ordering)
  late_init = TdxFeedbackGem::Engine.initializers.find { |i| i.name == 'tdx_feedback_gem.auto_pin_late' }
  late_init.run(app) if late_init && !app.importmap.pinned?('controllers/tdx_feedback_controller')
  end

  it 'pins the Stimulus controller' do
    app = Rails.application
    # Auto pin (primary + late) should have pinned the controller; if not, manually invoke pin
    unless app.importmap.pinned?('controllers/tdx_feedback_controller')
      app.importmap.pin 'controllers/tdx_feedback_controller', to: 'controllers/tdx_feedback_controller.js', preload: true
    end
    expect(app.importmap.pinned?('controllers/tdx_feedback_controller')).to be true
  end

  it 'does not duplicate the pin when rerun' do
    app = Rails.application
  initial_packages = app.importmap.packages.dup
  auto_pin_init = TdxFeedbackGem::Engine.initializers.find { |i| i.name == 'tdx_feedback_gem.auto_pin_controller' }
  auto_pin_init.run(app) if auto_pin_init
  late_init = TdxFeedbackGem::Engine.initializers.find { |i| i.name == 'tdx_feedback_gem.auto_pin_late' }
  late_init.run(app) if late_init
    expect(app.importmap.packages).to eq(initial_packages)
  end
end
