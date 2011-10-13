module Netzke
  module Communitypack
    # 2 grids - "container" and "collection" - bound with a one-to-many relationship.
    # The collection model should implement belongs_to in respect to the container model.
    #
    # Accepts the following config options:
    # * :container_model - name of the container model, e.g. "User"
    # * :collection_model - name of the collection model, e.g. "Issue" (belongs_to :user)
    # * :container_config (optional) - a config hash passed to the container grid
    # * :collection_config (optional) - a config hash passod to the collection grid
    # * :association (optional) - the name of the association used in belongs_to macro. Defaults to the underscored name of the container model.
    class OneToManyExplorer < Netzke::Basepack::BorderLayoutPanel
      js_mixin

      def default_config
        super.tap do |c|
          c[:container_config] = {:region => :west, :class_name => "Netzke::Basepack::GridPanel"}
          c[:collection_config] = {:class_name => "Netzke::Basepack::GridPanel"}
        end
      end

      def configuration
        super.tap do |c|
          c[:container_config][:width] ||= 300 if [:west, :east].include?(c[:container_config][:region].to_sym)
          c[:container_config][:height] ||= 150 if [:north, :south].include?(c[:container_config][:region].to_sym)

          c[:container_config][:model] ||= c[:container_model]
          c[:collection_config][:model] ||= c[:collection_model]

          container_class = c[:container_config][:model].constantize
          collection_class = c[:collection_config][:model].constantize
          c[:association] ||= c[:container_config][:model].underscore.to_sym # the belongs_to association, e.g. "user"

          association = collection_class.reflect_on_association(c[:association])

          c[:items] = [
            c[:container_config].merge(:item_id => 'container'),

            c[:collection_config].merge(
              :region => :center,
              :item_id => 'collection',
              :scope => {association.foreign_key.to_sym => component_session[:selected_container_record_id]},
              :strong_default_attrs => {association.foreign_key.to_sym => component_session[:selected_container_record_id]},
              :load_inline_data => false
            )
          ]
        end
      end

      endpoint :select_container_record do |params|
        # store selected container record id in the session for this component's instance
        component_session[:selected_container_record_id] = params[:id]
      end

    end
  end
end