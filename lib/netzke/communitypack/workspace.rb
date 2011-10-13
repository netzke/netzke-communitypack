module Netzke
  module Communitypack
    # A component that allows for dynamical loading/unloading of other Netzke components in tabs.
    # It can be manipulated by calling the <js>loadChild</js> method, e.g.:
    #
    #   workspace.loadChild("UserGrid", {newTab: true})
    #
    # - will load a UserGrid component from the server in a new tab.
    class Workspace < Netzke::Base
      js_base_class "Ext.tab.Panel"
      js_property :prevent_header, true

      js_mixin

      action :remove_all

      def default_config
        super.tap do |c|
          c[:items] = stored_tabs.each_with_index.map do |tab,i|
            {
              :layout => 'fit',
              :title => tab[:title],
              :closable => i > 0, # all closable except first
              :netzke_component_id => tab[:name],
              :items => !components[tab[:name].to_sym][:lazy_loading] && [tab[:name].to_sym.component]
            }
          end

          # c[:bbar] = [:remove_all.action]
        end
      end


      # Overriding this to allow for dynamically declared components
      def components
        stored_tabs.inject({}){ |r,tab| r.merge(tab[:name].to_sym => tab.reverse_merge(:prevent_header => true, :lazy_loading => true)) }
      end

      # Overriding the deliver_component endpoint, to dynamically add tabs and replace components in existing tabs
      def deliver_component_endpoint(params)
        cmp_name = params[:name]
        cmp_index = cmp_name.sub("cmp", "").to_i

        if params[:component].present?
          current_tabs = stored_tabs

          # we need to instantiate the newly added child to get access to its title
          cmp_class = constantize_class_name(params[:component])
          raise RuntimeError, "Could not find class #{params[:component]}" if cmp_class.nil?

          cmp_config = {:name => params[:name], :class_name => cmp_class.name}.merge(params[:config] || {}).symbolize_keys
          cmp_instance = cmp_class.new(cmp_config, self)
          new_tab_short_config = cmp_config.merge(:title => cmp_instance.js_config[:title] || cmp_instance.class.js_properties[:title]) # here we set the title

          if cmp_index >= stored_tabs.last[:name].sub("cmp", "").to_i
            # add new tab to persistent storage
            current_tabs << new_tab_short_config
          else
            # replace existing tab in the storage
            current_tabs[cmp_index] = new_tab_short_config
          end

          component_session[:items] = current_tabs
          @stored_tabs = nil # reset cache
        end

        super(params)
      end

      # Clean the session on request. More clean-up may be needed later, as we start using persistent configuration.
      endpoint :server_remove_all do |params|
        component_session[:items] = nil
      end

      # Removes a closed tab's component from the storage.
      endpoint :server_remove_tab do |params|
        component_session[:items].delete_if{ |item| item[:name] == params[:name] }
        {}
      end

      private

        # We store these in component_session atm. May as well be in persistent storage, depending on the requirements
        def stored_tabs
          @stored_tabs ||= component_session[:items].nil? ? [{:name => 'cmp0', :title => "Dashboard", :prevent_header => true, :closable => false, :lazy_loading => false, :class_name => "Netzke::Basepack::Panel"}] : component_session[:items]
        end

    end
  end
end