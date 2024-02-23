# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sinject/version'

Gem::Specification.new do |spec|
  spec.name          = 'sinject'
  spec.version       = Sinject::VERSION
  spec.authors       = ['Sage One']
  spec.email         = ['vaughan.britton@sage.com']

  spec.summary       = 'Simple Dependency Injection.'
  spec.description   = 'A simple dependency injection framework.'
  spec.homepage      = 'https://github.com/sage/sinject'
  spec.license       = 'MIT'

  spec.files         = Dir.glob("{bin,lib}/**/**/**")
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov_json_formatter'
end
