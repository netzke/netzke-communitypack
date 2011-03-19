# -*- encoding: utf-8 -*-
require File.expand_path("../lib/netzke/communitypack/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "netzke-communitypack"
  s.version     = Netzke::Communitypack::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Paul Spieker']
  s.email       = ['p.spieker@duenos.de']
  s.homepage    = "http://github.com/skozlov/netzke-communitypack"
  s.summary     = "Components for Netzke created by the community"
  s.description = "The community pack for netzke contains components for Netzke which are provided by the community"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "netzke-communitypack"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_paths = ['lib']

  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency 'netzke-basepack', '>= 0.6.0'
end
