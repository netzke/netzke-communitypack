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

      delegates_to_dsl :container_model, :collection_model, :container_config, :collection_config, :association

      js_properties(
        :prevent_header => true,
        :border => true
      )

      def configure
        super

        # merge default container and collection config with the one provided by the user
        config.container_config = {
          :region => :west,
          :class_name => "Netzke::Basepack::GridPanel"
        }.merge(config.container_config || {})

        config.collection_config = {
          :class_name => "Netzke::Basepack::GridPanel"
        }.merge(config.collection_config || {})

        # set default width/height for regions
        config.container_config[:width] ||= 300 if [:west, :east].include?(config.container_config[:region].to_sym)
        config.container_config[:height] ||= 200 if [:north, :south].include?(config.container_config[:region].to_sym)

        # figure out collection_class from config or from the passed component
        container_class = config.container_config[:model].try(:constantize) || config.container_config[:class_name].constantize.new.data_class
        collection_class = config.collection_config[:model].try(:constantize) || config.collection_config[:class_name].constantize.new.data_class

        # use the shortcuts for models
        config.container_config[:model] ||= config.container_model || container_class.name
        config.collection_config[:model] ||= config.collection_model || collection_class.name

        # we need to get the association reflection in order to properly set the collection grid scope
        config.association ||= config.container_config[:model].underscore.to_sym # the belongs_to association, e.g. "user"

        association = collection_class.reflect_on_association(config.association)

        # if we have extra scopes received in the config, take them into account!
        passed_scope = config.collection_config[:scope] || {}
        passed_strong_default_attrs = config.collection_config[:strong_default_attrs] || {}

        config.items = [
          config.container_config.merge(:item_id => 'container'),


          config.collection_config.merge(
            :region => :center,
            :item_id => 'collection',
            :scope => {association.foreign_key.to_sym => component_session[:selected_container_record_id]}.merge(passed_scope),
            :strong_default_attrs => {association.foreign_key.to_sym => component_session[:selected_container_record_id]}.merge(passed_strong_default_attrs),
            :load_inline_data => false
          )
        ]
      end

      endpoint :select_container_record do |params|
        # store selected container record id in the session for this component's instance
        component_session[:selected_container_record_id] = params[:id]
      end

    end
  end
end
