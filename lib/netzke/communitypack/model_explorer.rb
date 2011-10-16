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

      def configuration
        super.tap do |c|

          # merge default container and collection config with the one provided by the user
          c[:grid_config] = {
            :region => :west,
            :class_name => "Netzke::Basepack::GridPanel",
            :model => c[:model],
            :item_id => 'grid'
          }.merge(c[:grid_config] || {})

          c[:form_config] = {
            :class_name => "Netzke::Basepack::FormPanel",
            :model => c[:model],
            :region => :center,
            :item_id => 'form'
          }.merge(c[:form_config] || {})

          # set default width/height for regions
          c[:grid_config][:width] ||= 300 if [:west, :east].include?(c[:grid_config][:region].to_sym)
          c[:grid_config][:height] ||= 150 if [:north, :south].include?(c[:grid_config][:region].to_sym)

          c[:items] = [c[:grid_config], c[:form_config]]
        end
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