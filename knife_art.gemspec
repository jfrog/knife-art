# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-art/version'

Gem::Specification.new do |spec|
  spec.name           = 'knife-art'
  spec.version        = Knife::KnifeArt::VERSION
  spec.authors        = ['Dan Feldman']
  spec.email          = ['art-dev@jfrog.com']
  spec.license        = 'Apache-2.0'
  spec.homepage       = 'https://github.com/JFrogDev/knife-art'
  spec.summary        = %q{Artifactory integration for Knife}
  spec.description    = %q{Enables basic authentication support for share and upload operations to Artifactory when it serves as a Supermarket.}

  spec.files          = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths  = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
end
