# frozen_string_literal: true

module TdxFeedbackGem
  class Engine < ::Rails::Engine
    isolate_namespace TdxFeedbackGem

    initializer 'tdx_feedback_gem.assets' do |app|
      # Precompile engine styles for host apps when Sprockets is available
      if app.config.respond_to?(:assets) && app.config.assets.respond_to?(:precompile)
        app.config.assets.precompile += %w[tdx_feedback_gem.css]
      end
    end
  end
end
