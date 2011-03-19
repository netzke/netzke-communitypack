# External dependencies
require 'netzke-base'
require 'active_support/dependencies'

# Make components auto-loadable
ActiveSupport::Dependencies.autoload_paths << File.dirname(__FILE__)

require 'netzke/communitypack'

module Netzke
  module Communitypack
    class Engine < Rails::Engine
    end
  end
end

I18n.load_path << File.dirname(__FILE__) + '/../locales/en.yml'

Netzke::Communitypack.init
