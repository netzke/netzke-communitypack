{
  initComponent: function(){
    this.callParent();

    this.on('drop', this.updateLayout, this);

    this.setCloseEvents();

    // updating all portlets periodically
    // setInterval(Ext.Function.bind(this.updateAllWidgets, this), 3000);
  },

  afterRender: function() {
    this.callParent(arguments);

    // incremented index for dynamically added components
    this.netzkePortletIndex = this.allPortlets(true).length;
  },

  setCloseEvents: function() {
    Ext.each(this.allPortlets(), function(portlet) {
      portlet.on('destroy', this.updateLayout, this);
    }, this);
  },

  // Informs the server about the current layout
  updateLayout: function() {
    var portlets = [];
    this.items.each(function(column){
      var columnPortlets = [];
      column.items.each(function(portlet){
        columnPortlets.push({
          item_id: portlet.itemId,
          // name: portlet.name,
          // title: portlet.title,
          // height: portlet.getHeight()
        });
      });
      portlets.push({items: columnPortlets});
    });

    this.serverUpdateLayout({layout: portlets});
  },

  updateAllWidgets: function() {
    Ext.each(this.allPortlets(true), function(portlet) {
      var netzkeWidget = portlet.items.first();
      if (netzkeWidget && Ext.isFunction(netzkeWidget.refresh)) netzkeWidget.refresh();

      // Also try 1 level up...
      if (Ext.isFunction(portlet.refresh)) portlet.refresh();
    });
  },

  // Experimenting with changing the layout on the fly.
  // onOneColumnLayout: function() {
  //   var allPortlets = this.allPortlets();
  //
  //   this.add({items: allPortlets});
  //
  //   this.items.each(function(column) {
  //     column.destroy();
  //     return this.items.getCount() > 1;
  //   }, this);
  //
  //   // console.info("allPortlets: ", allPortlets);
  //
  // },

  // Returns all (Netzke) portlets
  // protected
  allPortlets: function(netzkeOnly) {
    return netzkeOnly ? this.query("portlet[isNetzke=true]") : this.query("portlet");
  },

  /*
  Params:
  * config - config for the portlet, e.g. {class_name: "MyPortlet"}
  */
  addPortlet: function(config) {
    this.loadNetzkeComponent({name: "netzke_" + this.netzkePortletIndex, params: config, callback: function(c){
      this.items.first().add(c);
    }});
    this.netzkePortletIndex += 1;
  }
}
