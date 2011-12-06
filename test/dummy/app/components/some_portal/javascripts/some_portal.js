{
  initComponent: function() {
    this.tools = this.tools || [];
    this.tools.push({type: 'gear', handler: this.onConfigure, scope: this});
    
    this.callParent();
  },
  
  onConfigure: function() {
    this.loadNetzkeComponent({name: "gallery_window", callback: function(w) {
      w.show();
    }});
  },
  
  onAddServerStatsPortlet: function() {
    this.addPortlet({class_name: "Portlet::ServerStats"});
  },

  onAddCpuChartPortlet: function() {
    this.addPortlet({class_name: "Portlet::CpuChart"});
  }
}