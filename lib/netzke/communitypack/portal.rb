module Netzke
  module Communitypack
    # A component based on Ext.app.PortalPanel with the following features:
    # 
    # * dynamic loading of portlets from the server (by calling the `addPortlet` JS method)
    # * dynamic deleting of portlets from the server (by pressing the close tool)
    # * storing portlets layout in the session while dragging portlets around
    # 
    # TODO: implement other persistence besides the session-based one
    class Portal < Netzke::Base
      js_base_class "Ext.app.PortalPanel"

      js_mixin

      title "My Portal"

      js_property :prevent_header, false

      # Override original Portal setting in order to look like a panel - e.g. have the header, toolbars, etc
      js_property :component_layout, "dock"

      # Portal-related Ext JS javascripts
      portal_path = Netzke::Core.ext_path.join("examples/portal")

      js_include(portal_path.join("classes/PortalColumn.js"))
      js_include(portal_path.join("classes/PortalDropZone.js"))
      js_include(portal_path.join("classes/PortalPanel.js"))

      # ... and styles
      css_include(portal_path.join("portal.css"))

      def js_config
        super.tap do |c|
          # we'll store the items in persistence storage
          c[:items] = component_session[:layout] ||= c[:items]
        end
      end

      def components
        # we'll store components in persistence storage
        super.tap do |comps|
          comps.merge!(component_session[:components] || {})
        end
      end

      endpoint :server_update_layout do |params|
        # we will extend the received layout (containing only item_ids) with full-config hashes
        new_layout = params[:layout]

        # all currently used items
        flatten_items = []
        iterate_items(js_config[:items]){ |item| flatten_items << item }

        # replace hashes in receved layout with full-config hashes from flatten_items
        iterate_items(new_layout) do |current_item|
          # detect full-config by item_id
          full_config_item = flatten_items.detect{ |item| item[:netzke_component].to_s == current_item["item_id"] || item[:item_id] == current_item["item_id"] }

          current_item.merge!(full_config_item)
        end

        # store new layout
        component_session[:layout] = new_layout

        {}
      end

      js_method :on_one_column_layout, <<-JS
        function(){
          this.serverUpdateLayout();
        }
      JS

      js_method :on_reset_layout, <<-JS
        function(){
          this.serverResetLayout();
        }
      JS

      # Reset to use initial items
      endpoint :server_reset_layout do |params|
        component_session[:portlets] = nil
        component_session[:components] = nil
        component_session[:layout] = nil
      end

      def deliver_component_endpoint(params)
        if params[:name] =~ /^netzke_/ # TODO: rename to portlet_
          cmp_name = params[:name]
          cmp_index = cmp_name.sub("netzke_", "").to_i

          # add new component to components hash first
          component_session[:components] ||= {}
          component_session[:components].merge!(cmp_name.to_sym => portlet_config(params))

          # add it also into the layout
          component_session[:layout].first[:items] << cmp_name.to_sym.component
        end

        super
      end

      protected

        # Iterates through provided items recursively and yields each found config hash
        def iterate_items(items_array, &block)
          items_array.each do |item|
            items = item[:items] || item["items"]
            items.is_a?(Array) ? iterate_items(items, &block) : yield(item)
          end
        end

        # Returns added portlet config based on provided params. The default implementation just passes params directly. This way the JS side can simply specify the complete portlet configuration in the request (not too safe).
        def portlet_config(params)
          params
        end

    end
  end
end

