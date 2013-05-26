$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "netzke-communitypack/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "netzke-communitypack"
  s.version     = NetzkeCommunitypack::VERSION
  s.authors     = ["nomadcoder"]
  s.email       = ["nmcoder@gmail.com"]
  s.homepage    = "http://writelesscode.com"
  s.summary     = "Community-created Netzke components"
  s.description = "Components that have been added by different people, but haven't yet found their way to Netzke Basepack - a kind of staging for new components."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "netzke-basepack", ">= 0.8.0"
  s.add_dependency "rails", ">= 3.0.0"

  s.add_development_dependency "sqlite3"
end
