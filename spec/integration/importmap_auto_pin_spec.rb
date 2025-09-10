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
      app.config.importmap.paths << TdxFeedbackGem::Engine.root.join('app/javascript') unless app.config.importmap.paths.include?(TdxFeedbackGem::Engine.root.join('app/javascript'))
      app.config.importmap.cache_sweepers << TdxFeedbackGem::Engine.root.join('app/javascript') unless app.config.importmap.cache_sweepers.include?(TdxFeedbackGem::Engine.root.join('app/javascript'))
    end
    auto_pin_init = TdxFeedbackGem::Engine.initializers.find { |i| i.name == 'tdx_feedback_gem.auto_pin_controller' }
    auto_pin_init.run(app) if auto_pin_init
  end

  it 'pins the Stimulus controller' do
    app = Rails.application
  # Auto pin initializer should have pinned the controller
  expect(app.importmap.pinned?('controllers/tdx_feedback_controller')).to be true
  end

  it 'does not duplicate the pin when rerun' do
    app = Rails.application
  initial_packages = app.importmap.packages.dup
    auto_pin_init = TdxFeedbackGem::Engine.initializers.find { |i| i.name == 'tdx_feedback_gem.auto_pin_controller' }
    auto_pin_init.run(app) if auto_pin_init
    expect(app.importmap.packages).to eq(initial_packages)
  end
end
