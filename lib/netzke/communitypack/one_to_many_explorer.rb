module Netzke
  module Communitypack
    # 2 grids - "container" and "collection" - bound with a one-to-many relationship.
    # The collection model should implement belongs_to in respect to the container model.
    #
    # Accepts the following config options:
    # * foreign_key (required) - foreign key that defines the one-to-many relation
    #
    # Override :container and :collection components if you want to customize the corresponding grids, e.g.:
    #
    #     component :container do |c|
    #       c.klass = ProjectGrid
    #       c.region = :north
    #       c.height = 200
    #       super c
    #     end
    class OneToManyExplorer < Netzke::Base
      include Netzke::Basepack::ItemPersistence

      js_configure do |c|
        c.mixin
        c.prevent_header = true
        c.border = true
        c.layout = :border
      end

      def self.server_class_config_options
        [*super, :container_config, :collection_config]
      end

      def configure(c)
        c.items = [:container, :collection]
        super
      end

      endpoint :select_container_record do |params, this|
        # store selected container record id in the session for this component's instance
        component_session[:container_id] = params[:id]
      end

      component :container do |c|
        c.klass ||= Netzke::Basepack::Grid
        c.title ||= "Container"
        c.region ||= :west
        c.width ||= 300
        c.merge!(config.container_config || {})
      end

      component :collection do |c|
        c.klass ||= Netzke::Basepack::Grid

        c.region ||= :center
        c.load_inline_data = false

        collection_config = config.collection_config.try(:dup) || {} # dupping because config hash is frozen

        # Make sure the data in the collection grid is bound to the selected container record
        c.scope = (c.scope || {}).merge(config.foreign_key => component_session[:container_id]).merge(collection_config.delete(:scope) || {})
        c.strong_default_attrs = (c.strong_default_attrs || {}).merge(config.foreign_key => component_session[:container_id]).merge(collection_config.delete(:strong_default_attrs) || {})

        c.merge!(collection_config)
      end
    end
  end
end
