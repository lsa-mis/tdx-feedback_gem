# frozen_string_literal: true

require 'rails/generators'

module TdxFeedbackGem
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Installs TdxFeedbackGem by creating migration and initializer.'

      def copy_migration
        timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
        create_file "db/migrate/#{timestamp}_create_tdx_feedback_gem_feedbacks.rb",
                    File.read(File.join(self.class.source_root, 'migration.rb'))
      end

      def create_initializer
        template 'initializer.rb', 'config/initializers/tdx_feedback_gem.rb'
      end
    end
  end
end
