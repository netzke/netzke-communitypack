// Extends Ext.data.TreeStore and adds paging to it
Ext.define('Ext.netzke.PagingTreeStore', {
  extend: 'Ext.data.TreeStore',
  alias: 'pagingtreestore',
  currentPage: 1,
  config:{
   totalCount: null,
   pageSize: null
  },
  // Load a specific Page
  loadPage: function(page){
   var me = this;
me.currentPage = page;
me.read({
      page: page,
      start: (page - 1) * me.pageSize,
      limit: me.pageSize
    });
  },
  // Load next Page
  nextPage: function(){
   this.loadPage(this.currentPage + 1);
  },
  // Load previous Page
  previousPage: function(){
   this.loadPage(this.currentPage - 1);
  },
  // Overwrite function in order to set totalCount
  onProxyLoad: function(operation) {
   // This method must be overwritten in order to set totalCount
    var me = this,
        resultSet = operation.getResultSet(),
        node = operation.node;
    // If the node doesn't have a parent node, set totalCount
    if (resultSet && node.parentNode == null) {
        me.setTotalCount(resultSet.total);
    }
    // We're done here, call parent
this.callParent(arguments);
  },
  getCount : function(){
    return this.getRootNode().childNodes.length;
  },
  getRange : function(start, end){
    var me = this,
      items = this.getRootNode().childNodes,
      range = [],
      i;
    if (items.length < 1) {
      return range;
    }
    start = start || 0;
    end = Math.min(typeof end == 'undefined' ? items.length - 1 : end, items.length - 1);
    if (start <= end) {
      for (i = start; i <= end; i++) {
        range[range.length] = items[i];
      }
    } else {
      for (i = start; i >= end; i--) {
        range[range.length] = items[i];
      }
    }
    return range;
  }

  
});