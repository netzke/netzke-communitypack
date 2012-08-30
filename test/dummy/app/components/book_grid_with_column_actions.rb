# Implements a column action :delete_row
class BookGridWithColumnActions < Netzke::Basepack::GridPanel
  include Netzke::Communitypack::ActionColumn

  def configure(c)
    c.model = "Book"
    c.columns = [:title, :basic_actions, :extra_actions]
    super
  end

  column :basic_actions do |c|
    c.type = :action
    c.actions = [{name: :delete_row, tooltip: "Delete row", icon: "#{Netzke::Core.ext_uri}/examples/shared/icons/fam/delete.gif"}]
  end

  # Just for illustation (have no handler)
  column :extra_actions do |c|
    c.type = :action
    c.actions = [:error, :information]
  end

  js_configure do |c|
    c.on_delete_row = <<-JS
      function(record){
        this.getSelectionModel().select(record);
        this.onDel();
      }
    JS
  end
end
