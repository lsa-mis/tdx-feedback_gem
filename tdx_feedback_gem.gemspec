# frozen_string_literal: true

require_relative "lib/tdx_feedback_gem/version"

Gem::Specification.new do |spec|
  spec.name          = "tdx_feedback_gem"
  spec.version       = TdxFeedbackGem::VERSION
  spec.authors       = ["Your Name or Team"]
  spec.email         = ["your-email@example.com"]

  spec.summary       = "Rails engine for TDX feedback integration"
  spec.description   = "Provides controllers, views, and Stimulus controllers to collect and send feedback to TeamDynamix (TDX)."
  spec.homepage      = "https://github.com/lsa-mis/tdx-feedback_gem"
  spec.license       = "MIT"

  # Required Ruby version
  spec.required_ruby_version = ">= 3.0"

  # Which files to include in the gem
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "rails", ">= 6.1", "< 8.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
end
