# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../communitypack_test_app/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
