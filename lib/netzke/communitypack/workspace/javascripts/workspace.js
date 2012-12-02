{
  initComponent: function() {
    this.callParent();

    this.on('tabchange', function(panel, tab) {
      if (tab.netzkeComponentId == 'cmp0' && this.alwaysReloadFirstTab) {
        tab.removeAll();
      }

      if (tab.items.getCount() == 0) {
        var cmpName = tab.netzkeComponentId;
        this.netzkeLoadComponent({name: cmpName, container: tab});
      }
    });

    this.on('remove', function(me, tab) {
      if (tab.getXType() == 'panel') {
        this.serverRemoveTab({name: tab.netzkeComponentId});
      }
    }, this);
  },

  // Closes all tabs except first (Dashboard)
  closeAllTabs: function() {
    while (this.items.getCount() > 1) {
      this.remove(this.items.last());
    }

    this.serverRemoveAll();
  },

  /**
  * Loads a component.
  */
  loadInTab: function(cmp, options) {
    var tabCount = this.items.getCount(),
        cmpName,
        receivingTab,
        params;

    options = options || {};

    // always open a new tab whene only dashboard is present
    options.newTab = options.newTab || tabCount < 2

    if (options.newTab) {
      var lastTabIndex = parseInt(this.items.last().netzkeComponentId.replace("cmp", ""));
      cmpName = "cmp" + (lastTabIndex + 1);
      receivingTab = this.add({layout: 'fit', closable: true});
    } else {
      // receiving tab will be the active tab, unless that is the dashboard, in which case it will be the last tab
      receivingTab = this.getActiveTab();
      if (receivingTab == this.items.first()) {
        receivingTab = this.items.last();
      }
      cmpName = "cmp" + this.items.indexOf(receivingTab);
    }

    this.suspendEvents();
    this.setActiveTab(receivingTab);
    this.resumeEvents();

    receivingTab.setTitle('Loading...');

    receivingTab.removeAll();

    params = {component: cmp};
    params.config = options.config;

    this.netzkeLoadComponent({name: cmpName, container: receivingTab, params: params, callback: function(c) {
      receivingTab.setTitle(c.title);
      receivingTab.netzkeComponentId = c.itemId;
    }});
  }
}
