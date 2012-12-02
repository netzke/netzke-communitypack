module Netzke
  module Communitypack
    # 2 regions - "grid" and "form", form displaying the details of the record selected in the grid.
    #
    # Accepts the following config options:
    # * :model - name of the model, e.g. "User"
    # * :grid_config (optional) - a config hash passed to the grid
    # * :form_config (optional) - a config hash passed to the form
    class ModelExplorer < Netzke::Base
      include Netzke::Basepack::ItemPersistence

      js_configure do |c|
        c.prevent_header = true
        c.layout = :border
        c.init_component = <<-JS
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

      def self.server_side_config_options
        [*super, :form_config, :grid_config]
      end

      component :grid do |c|
        passed_config = config.grid_config || {}
        passed_config[:region] ||= :west
        passed_config[:width] ||= 300 if [:west, :east].include?(passed_config[:region])
        passed_config[:width] ||= 150 if [:north, :south].include?(passed_config[:region])

        c.klass = Netzke::Basepack::Grid
        c.split = true
        c.model = config.model

        c.merge!(passed_config)
      end

      component :form do |c|
        c.klass = Netzke::Basepack::Form
        c.model = config.model
        c.region = :center
        c.merge!(config.form_config || {})
      end

      def configure(c)
        c.items = [:grid, :form]
        super
      end

      endpoint :select_record do |params, this|
        # store selected container record id in the session for this component's instance
        component_session[:selected_record_id] = params[:id]
      end
    end
  end
end
