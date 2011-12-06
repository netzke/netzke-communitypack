class SomePortal < Netzke::Communitypack::Portal
  title "Some Portal"

  js_mixin

  # Actions
  action :one_column_layout
  action :reset_layout
  action :add_server_stats_portlet
  action :add_cpu_chart_portlet

  js_property :tbar, [:add_server_stats_portlet.action, :add_cpu_chart_portlet.action, "-", :reset_layout.action]

  # Initial portlets.
  items [{
    items: [
      # {:class_name => "Portlet::CpuChart"}
    ]
  }, {
    items: [
      # {:class_name => "Portlet::ClerkForm"}
    ]
  }, {
    items: [
      # {:class_name => "Portlet::ServerStats"},
      # {
      #   xtype: :portlet,
      #   title: "Portlet 3,1",
      #   item_id: 'ext_portlet1',
      #   height: 200
      # }
    ]
  }]

  component :gallery_window, :class_name => "Netzke::Basepack::Window", :width => 500, :height => 400, :lazy_loading => true
end
