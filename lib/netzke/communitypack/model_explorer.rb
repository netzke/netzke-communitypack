module Netzke
  module Communitypack
    # 2 regions - "grid" and "form", form displaying the details of the record selected in the grid.
    #
    # Accepts the following config options:
    # * :model - name of the model, e.g. "User"
    # * :grid_config (optional) - a config hash passed to the grid
    # * :form_config (optional) - a config hash passed to the form
    class ModelExplorer < Netzke::Basepack::BorderLayoutPanel

      delegates_to_dsl :model, :grid_config, :form_config

      js_properties(
        :prevent_header => true,
        :border => true
      )

      def configure
        super

        # merge default container and collection config with the one provided by the user
        config.grid_config = {
          :region => :west,
          :class_name => "Netzke::Basepack::GridPanel",
          :model => config.model,
          :item_id => 'grid'
        }.merge(config.grid_config || {})

        config.form_config = {
          :class_name => "Netzke::Basepack::FormPanel",
          :model => config.model,
          :region => :center,
          :item_id => 'form'
        }.merge(config.form_config || {})

        # set default width/height for regions
        config.grid_config[:width] ||= 300 if [:west, :east].include?(config.grid_config[:region].to_sym)
        config.grid_config[:height] ||= 150 if [:north, :south].include?(config.grid_config[:region].to_sym)

        config.items = [config.grid_config, config.form_config]
      end

      endpoint :select_record do |params|
        # store selected container record id in the session for this component's instance
        component_session[:selected_record_id] = params[:id]

        # {:form => {:set_title => "Blah"}}
      end

      js_method :init_component, <<-JS
        function(){
          // calling superclass's initComponent
          this.callParent();

          this.grid = this.getComponent('grid');
          this.form = this.getComponent('form');

          // setting the 'rowclick' event
          this.grid.getView().on('itemclick', function(view, record){
            this.selectRecord({id: record.getId()});
            this.form.netzkeLoad({id: record.getId()});
          }, this);
        }
      JS
    end
  end
end
