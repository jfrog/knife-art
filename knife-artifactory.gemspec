# coding: utf-8
$:.unshift(File.dirname(__FILE__) + '/lib')
require 'knife-artifactory/version'

Gem::Specification.new do |spec|
  spec.name           = 'knife-artifactory'
  spec.version        = KnifeArtifactory::VERSION
  spec.authors        = ['Dan Feldman']
  spec.email          = ['art-dev@jfrog.com']
  spec.license        = 'Apache-2.0'
  spec.homepage       = 'https://github.com/jasonwbarnett/knife-artifactory'
  spec.summary        = %q{Artifactory integration for Knife}
  spec.description    = %q{Enables basic authentication support for share and upload operations to Artifactory when it serves as a Supermarket.}

  spec.files          = Dir.glob('lib/**/*')
  spec.require_paths  = ['lib']
end
