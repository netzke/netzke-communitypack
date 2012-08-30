module Netzke
  module Communitypack
    module ActionColumn
      extend ActiveSupport::Concern

      included do |base|
        js_configure do |c|
          c.include :action_column
        end
      end

      # This can be optimized in order to generate less json in the column getter
      def augment_column_config(c)
        if c[:type] == :action
          c.xtype = :netzkeactioncolumn
          c[:getter] = lambda do |r|
            c.actions.map do |a|
              a = {name: a} if a.is_a?(Symbol)
              a.tap do |a|
                a[:tooltip] ||= a[:name].to_s.humanize
                a[:icon] ||= "/extjs/examples/shared/icons/fam/#{a[:name]}.png"
                a[:handler] ||= "on_#{a[:name]}"
              end
            end.to_nifty_json
          end
        end

        super
      end
    end
  end
end
