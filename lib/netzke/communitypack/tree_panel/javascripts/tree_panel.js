{
  trackMouseOver: true,
  loadMask: true,
  componentLoadMask: {msg: "Loading..."},
  deleteMaskMsg: "Deleting...",
  initComponent: function(){
    var metaColumn;
    var fields = this.extraFields; // field configs for the underlying data model

    this.plugins = this.plugins || [];
    this.features = this.features || [];

    // Run through columns and set up different configuration for each
    Ext.each(this.columns, function(c, i){

      this.normalizeRenderer(c);

      // Build the field configuration for this column
      var fieldConfig = {name: c.dataIndex, defaultValue: c.defaultValue};

      if (c.name !== '_meta') fieldConfig.type = this.fieldTypeForAttrType(c.attrType); // field type (grid editors need this to function well)

      if (c.attrType == 'datetime') {
        fieldConfig.dateFormat = 'Y-m-d g:i:s'; // in this format we receive dates from the server

        if (!c.renderer) {
          c.renderer = Ext.util.Format.dateRenderer(c.format || fieldConfig.dateFormat); // format in which the data will be rendered
        }
      };

      if (c.attrType == 'date') {
        fieldConfig.dateFormat = 'Y-m-d'; // in this format we receive dates from the server

        if (!c.renderer) {
          c.renderer = Ext.util.Format.dateRenderer(c.format || fieldConfig.dateFormat); // format in which the data will be rendered
        }
      };

      fields.push(fieldConfig);

      // We will not use meta columns as actual columns (not even hidden) - only to create the records
      if (c.meta) {
        metaColumn = c;
        return;
      }
      
      // Set rendeder for association columns (the one displaying associations by the specified method instead of id)
      if (c.assoc) {
        // Editor for association column
        c.editor = Ext.apply({
          parentId: this.id,
          name: c.name,
          selectOnFocus: true // ?
        }, c.editor);

        // Renderer for association column
        this.normalizeAssociationRenderer(c);
      }

      if (c.editor) {
        Ext.applyIf(c.editor, {selectOnFocus: true});
      }

      // Setting the default filter type
      if (c.filterable && !c.filter) {
        c.filter = {type: this.fieldTypeForAttrType(c.attrType)};
      }

      // HACK: somehow this is not set by Ext (while it should be)
      if (c.xtype == 'datecolumn') c.format = c.format || Ext.util.Format.dateFormat;

    }, this);
    /* ... and done with the columns */

    // Define the model
    Ext.define(this.id, {
      extend: 'Ext.data.Model',
      idProperty: this.pri, // Primary key
      fields: fields
    });

    // After we created the record (model), we can get rid of the meta column
    Ext.Array.remove(this.columns, metaColumn);

    // Prepare column model config with columns in the correct order; columns out of order go to the end.
    var colModelConfig = [];
    var columns = this.columns;

    Ext.each(this.columns, function(c) {
      var mainColConfig;
      Ext.each(this.columns, function(oc) {
        if (c.name === oc.name) {
          mainColConfig = Ext.apply({}, oc);
          return false;
        }
      });

      colModelConfig.push(Ext.apply(mainColConfig, c));
    }, this);

    // We don't need original columns any longer
    delete this.columns;

    // ... instead, define own column model
    this.columns = colModelConfig;

    // DirectProxy that uses our Ext.direct provider
    var proxy = {
      type: 'direct',
      directFn: Netzke.providers[this.id].getData,
      reader: {
        type: 'json',
        root: 'data'
      },
      listeners: {
        exception: {
          fn: this.loadExceptionHandler,
          scope: this
        },
        load: { // Netzke-introduced event; this will also be fired when an exception occurs.
          fn: function(proxy, response, operation) {
            // besides getting data into the store, we may also get commands to execute
            response = response.result;

            if (response) { // or did we have an exception?
              Ext.each(['data', 'total', 'success'], function(property){delete response[property];});
              this.netzkeBulkExecute(response);
            }
          },
          scope: this
        }
      }
    }

    // Create the netzke PagingTreeStore
    this.store = Ext.create('Ext.netzke.PagingTreeStore', {
      model: this.id,
      proxy: proxy,
      root: this.inlineData || {data: []},
      pageSize: this.rowsPerPage
    });
    this.store.load();
    // HACK: we must let the store now totalCount
    this.store.setTotalCount(this.inlineData && this.inlineData[this.store.getProxy().getReader().totalProperty]);
    
    // Drag'n'Drop
    if (this.enableRowsReordering){
      this.ddPlugin = new Ext.ux.dd.GridDragDropRowOrder({
        scrollable: true // enable scrolling support (default is false)
      });
      this.plugins.push(this.ddPlugin);
    }

    // Cell editing
    if (!this.prohibitUpdate) {
      this.plugins.push(Ext.create('Ext.grid.plugin.CellEditing', {pluginId: 'celleditor'}));
    }

    // Toolbar
    this.dockedItems = this.dockedItems || [];
    if (this.enablePagination) {
      this.dockedItems.push({
        xtype: 'pagingtoolbar',
        dock: 'bottom',
        store: this.store,
        items: this.bbar && ["-"].concat(this.bbar) // append the old bbar. TODO: get rid of it.
      });
    } else if (this.bbar) {
      this.dockedItems.push({
        xtype: 'toolbar',
        dock: 'bottom',
        items: this.bbar
      });
    }

    delete this.bbar;

    // Now let Ext.grid.EditorGridPanel do the rest (original initComponent)
    this.callParent();

    // Context menu
    if (this.contextMenu) {
      this.on('itemcontextmenu', this.onItemContextMenu, this);
    }

    // Disabling/enabling editInForm button according to current selection
    if (this.enableEditInForm && !this.prohibitUpdate) {
      this.getSelectionModel().on('selectionchange', function(selModel, selected){
        var disabled;
        if (selected.length === 0) { // empty?
          disabled = true;
        } else {
          // Disable "edit in form" button if new record is present in selection
          Ext.each(selected, function(r){
            if (r.isNew) { disabled = true; return false; }
          });
        };
        this.actions.editInForm.setDisabled(disabled);
      }, this);
    }


    // Drag n Drop event
    if (this.enableRowsReordering){
      this.ddPlugin.on('afterrowmove', this.onAfterRowMove, this);
    }

    // WIP: GridView
    this.getView().getRowClass = this.defaultGetRowClass;

    // When starting editing as assocition column, pre-load the combobox store from the meta column, so that we don't see the real value of this cell (the id of the associated record), but rather the associated record by the configured method.
    this.on('beforeedit', function(e){
      return false;
    }, this);

    this.on('afterrender', function() {
      // Persistence-related events (afterrender to avoid blank event firing on render)
      if (this.persistence) {
        // Inform the server part about column operations
        this.on('columnresize', this.onColumnResize, this);
        this.on('columnmove', this.onColumnMove, this);
        this.on('columnhide', this.onColumnHide, this);
        this.on('columnshow', this.onColumnShow, this);
      }
    }, this);
  },

  fieldTypeForAttrType: function(attrType){
    var map = {
      integer : 'int',
      decimal : 'float',
      datetime : 'date',
      date : 'date',
      string : 'string',
      text : 'string',
      'boolean' : 'boolean'
    };
    return map[attrType] || 'string';
  },

  // Normalizes the renderer for a column.
  // Renderer may be:
  // 1) a string that contains the name of the function to be used as renderer.
  // 2) an array, where the first element is the function name, and the rest - the arguments
  // that will be passed to that function along with the value to be rendered.
  // The function is searched in the following objects: 1) Ext.util.Format, 2) this.
  // If not found, it is simply evaluated. Handy, when as renderer we receive an inline JS function,
  // or reference to a function in some other scope.
  // So, these will work:
  // * "uppercase"
  // * ["ellipsis", 10]
  // * ["substr", 3, 5]
  // * "myRenderer" (if this.myRenderer is a function)
  // * ["Some.scope.Format.customRenderer", 10, 20, 30] (if Some.scope.Format.customRenderer is a function)
  // * "function(v){ return 'Value: ' + v; }"
  normalizeRenderer: function(c) {
    if (!c.renderer) return;

    var name, args = [];

    if ('string' === typeof c.renderer) {
      name = c.renderer.camelize(true);
    } else {
      name = c.renderer[0];
      args = c.renderer.slice(1);
    }

    // First check whether Ext.util.Format has it
    if (Ext.isFunction(Ext.util.Format[name])) {
       c.renderer = Ext.Function.bind(Ext.util.Format[name], this, args, 1);
    } else if (Ext.isFunction(this[name])) {
      // ... then if our own class has it
      c.renderer = Ext.Function.bind(this[name], this, args, 1);
    } else {
      // ... and, as last resort, evaluate it (allows passing inline javascript function as renderer)
      eval("c.renderer = " + c.renderer + ";");
    }
  },
  
  /*
Set a renderer that displayes association values instead of association record ID.
The association values are passed in the meta-column under associationValues hash.
*/
  normalizeAssociationRenderer: function(c) {
    c.scope = this;
    var passedRenderer = c.renderer; // renderer we got from normalizeRenderer
    c.renderer = function(value, a, r, ri, ci){
      var column = this.headerCt.items.getAt(ci),
          editor = column.getEditor && column.getEditor(),
          // HACK: using private property 'store'
          recordFromStore = editor && editor.isXType('combobox') && editor.store.findRecord('field1', value),
          renderedValue;

      if (recordFromStore) {
        renderedValue = recordFromStore.get('field2');
      } else if (c.assoc && r.get('_meta')) {
        renderedValue = r.get('_meta').associationValues[c.name] || value;
      } else {
        renderedValue = value;
      }

      return passedRenderer ? passedRenderer.call(this, renderedValue) : renderedValue;
    };
  }
}