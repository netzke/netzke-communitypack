class WorkspaceTester < Netzke::Base
  action :load_some_panel
  action :load_another_panel
  action :load_book_explorer

  def configure(c)
    super
    c.items = [:workspace]
    c.bbar = [:load_some_panel, :load_another_panel, :load_book_explorer]
  end

  component :workspace do |c|
    c.klass = Netzke::Communitypack::Workspace
  end

  js_configure do |c|
    c.layout = :fit
    c.on_load_some_panel = <<-JS
      function(){
        this.netzkeGetComponent('workspace').loadInTab("SomePanel");
      }
    JS
    c.on_load_another_panel = <<-JS
      function(){
        this.netzkeGetComponent('workspace').loadInTab("AnotherPanel", {newTab: true});
      }
    JS
    c.on_load_book_explorer = <<-JS
      function(){
        this.netzkeGetComponent('workspace').loadInTab("BookExplorer", {newTab: true});
      }
    JS
  end
end
