require 'netzke/communitypack/version'
require 'netzke/active_record'

module Netzke
  module Communitypack
    class << self

      # Called from netzke-communitypack.rb
      def init
      end

      # Use it to confirure Communitypack in the initializers, e.g.:
      #
      #     Netzke::Basepack.setup do |config|
      #       ...
      #     end
      def setup
        yield self
      end
    end

  end
end
