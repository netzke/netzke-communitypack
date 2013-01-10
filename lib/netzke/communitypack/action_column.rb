module Netzke
  module Communitypack
    module ActionColumn
      extend ActiveSupport::Concern

      included do |base|
        js_configure do |c|
          c.require :action_column
        end
      end

      # This can be optimized in order to generate less json in the column getter
      def augment_column_config(c)
        if c[:type] == :action
          c.xtype = :netzkeactioncolumn

          c[:getter] = lambda do |r|
            c.actions.map {|a| build_action_config(a)}.netzke_jsonify.to_json
          end
        end

        super
      end

    private

      def build_action_config(a)
        a = {name: a} if a.is_a?(Symbol)
        a.tap do |a|
          a[:tooltip] ||= a[:name].to_s.humanize
          a[:icon] ||= a[:name].to_sym
          a[:handler] ||= "on_#{a[:name]}"

          a[:icon] = "#{Netzke::Core.icons_uri}/#{a[:icon]}.png" if a[:icon].is_a?(Symbol)
        end
      end
    end
  end
end
