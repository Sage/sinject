# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

ci_version = ENV.fetch('CI_VERSION', '')
puts "CI version - #{ci_version}" unless ci_version.empty?

version = if ci_version =~ /\Av[0-9]+\.[0-9]+\.[0-9]+/
            ci_version[1..-1]
          else
            '0.0.0'
          end

Gem::Specification.new do |spec|
  spec.name          = 'sinject'
  spec.version       = version
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
