require File.join File.expand_path('lib', __dir__), 'introvert_tempmon/version'

Gem::Specification.new do |spec|
  spec.name          = 'introvert_tempmon'
  spec.version       = IntrovertTempmon::VERSION
  spec.authors       = ['Alexander Olofsson']
  spec.email         = ['ace@haxalot.com']

  spec.summary       = 'A Ruby collate system for temperature monitors'
  spec.description   = spec.summary
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(spec|test)/})
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sinatra'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
end
