Gem::Specification.new do |spec|
  spec.name          = 'tdx_feedback_gem'
  spec.version       = '0.1.0'
  spec.authors       = ['Rick Smoke']
  spec.email         = ['rsmoke@umich.edu']

  spec.summary       = 'A Ruby gem for collecting feedback, designed for Rails.'
  spec.description   = 'A Ruby gem for collecting and managing user feedback, easily integrated with Rails applications.'
  spec.homepage      = 'https://github.com/lsa-mis/tdx-feedback_gem'
  spec.license       = 'MIT'

  spec.files         = Dir['{lib,app}/**/*', 'README.md', 'LICENSE']
  spec.require_paths = ['lib']

  # Runtime dependencies for Rails integration
  spec.add_runtime_dependency 'actionpack', '>= 6.1', '< 8.0'
  spec.add_runtime_dependency 'activerecord', '>= 6.1', '< 8.0'
  spec.add_runtime_dependency 'railties', '>= 6.1', '< 8.0'

  spec.add_development_dependency 'rspec'
end
