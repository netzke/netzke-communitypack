module Netzke
  module Communitypack
    # A component that allows for dynamical loading/unloading of other Netzke components in tabs.
    # It can be manipulated by calling the +loadInTab+ method, e.g.:
    #
    #   workspace.loadInTab("UserGrid", {newTab: true})
    #
    # - will load a UserGrid component from the server in a new tab.
    #
    # ## Configuration
    #
    # Accepts the following options:
    #
    # * always_reload_first_tab (default false) - reload the first tab each time it gets activated
    class Workspace < Netzke::Base
      js_configure do |c|
        c.extend = "Ext.tab.Panel"
        c.header = false
        c.mixin
      end

      action :remove_all

      def configure(c)
        c.items = [:dashboard, *stored_tabs.map{|c| c[:component] = c[:name].to_sym}]
        # c.items = ([dashboard_config] + stored_tabs).each_with_index.map do |tab,i|
        #   {
        #     :layout => 'fit',
        #     :title => tab[:title],
        #     :closable => i > 0, # all closable except first
        #     :netzke_component_id => tab[:name],
        #     :items => components[tab[:name].to_sym][:eager_loading] && [tab[:name].to_sym]
        #   }
        # end

        super
      end

      def extend_item(item)
        item = super
        i = get_item_index
        c = component_instance(item[:netzke_component])
        { layout: :fit,
          title: c.config.title,
          closable: i > 0,
          netzke_component_id: :"cmp#{i}",
          items: i == 0 ? [item] : []
        }
      end

      def get_item_index
        @item_index ||= -1
        @item_index += 1
      end

      component :dashboard do |c|
        c.title = "Dashboard"
        c.klass = Netzke::Core::Panel
        c.header = false
        c.border = false
        c.html = "Dashboard"
        # c.component_id = :cmp0
        # c.item_id = :cmp0
        # c.eager_loading = true
      end

      # Overriding this to allow for dynamically declared components
      def components
        super.merge(stored_tabs.inject({}){ |r,tab| r.merge(tab[:name].to_sym => tab.reverse_merge(:header => false, :border => false)) })
      end

      # Overriding the deliver_component endpoint, to dynamically add tabs and replace components in existing tabs
      endpoint :deliver_component do |params, this|
        cmp_name = params[:name]
        cmp_index = cmp_name.sub("cmp", "").to_i

        if params[:component].present?
          current_tabs = stored_tabs

          # we need to instantiate the newly added child to get access to its title
          cmp_class = params[:component].constantize
          raise RuntimeError, "Could not find class #{params[:component]}" if cmp_class.nil?

          cmp_config = {:name => params[:name], :klass => cmp_class}.merge(params[:config] || {}).symbolize_keys
          cmp_instance = cmp_class.new(cmp_config, self)
          ::Rails.logger.debug "!!! cmp_instance.config:: #{cmp_instance.config.inspect}\n"
          new_tab_short_config = cmp_config.merge(:title => cmp_instance.config.title || cmp_instance.class.js_config.title) # here we set the title

          if stored_tabs.empty? || cmp_index > stored_tabs.last[:name].sub("cmp", "").to_i
            # add new tab to persistent storage
            current_tabs << new_tab_short_config
          else
            # replace existing tab in the storage
            current_tabs[current_tabs.index(current_tabs.detect{ |tab| tab[:name] == cmp_name })] = new_tab_short_config
          end

          update_state(:items, current_tabs)
          @stored_tabs = nil # invalidate cache
        end

        super(params, this)
      end

      # Clean the session on request. More clean-up may be needed later, as we start using persistent configuration.
      endpoint :server_remove_all do |params, this|
        state[:items] = []
      end

      # Removes a closed tab's component from the storage.
      endpoint :server_remove_tab do |params, this|
        state[:items].delete_if{ |item| item[:name] == params[:name] }
      end

      # We store these in component_session atm. May as well be in persistent storage, depending on the requirements
      def stored_tabs
        @stored_tabs ||= state[:items] || []
      end

    end
  end
end
