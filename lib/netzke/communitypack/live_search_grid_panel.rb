# The LiveSearchGridPanel provides a search field in the toolbar of the GridPanel. While the content
# of the search field is changeing, the data in the grid gets reloaded and the filter string is given
# to a scope on the configured model. The scope name by default is :live_search but it can be reconfigured
# by the configuration option :live_search_scope.
#
# Options:
# * +live_search_scope+ - The scope name for filtering the results by the live search (default: :live_search)
#
class Netzke::Communitypack::LiveSearchGridPanel < ::Netzke::Basepack::GridPanel
  def configure
    super
    config.merge!({
      :tbar => ['->', {
        :xtype => 'textfield',
        :enable_key_events => true,
        :name => 'live_search_field',
        :empty_text => 'Search'
      }]
    })
  end

  js_method :init_component, <<-JS
    function() {
      #{js_full_class_name}.superclass.initComponent.call(this);

      this.liveSearchBuffer = '';
      
      live_search_field = this.query('textfield[name="live_search_field"]')[0];
    
      // Add event listeners
      live_search_field.on('keydown', function() { this.onLiveSearch(); }, this, { buffer: 500 });
      live_search_field.on('blur', function() { this.onLiveSearch(); }, this, { buffer: 500 });
    }
  JS

  js_method :on_live_search, <<-JS
    function() {
      var search_text = this.live_search_field.getValue();
      if (search_text == this.liveSearchBuffer) return;
      this.liveSearchBuffer = search_text;
      Ext.apply(this.getStore().proxy.extraParams, {
        live_search : search_text
      });
      this.getStore().loadPage(1);
    }
  JS

  def get_data(*args)
    params = args.first
    search_scope = config[:live_search_scope] || :live_search
    data_class.send(search_scope, params && params[:live_search] || '').scoping do
      super
    end
  end

end
