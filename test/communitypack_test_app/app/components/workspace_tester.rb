class WorkspaceTester < Netzke::Base
  action :load_some_panel
  action :load_another_panel
  action :load_book_explorer
  action :load_configurable_panel
  action :load_grid

  def configure(c)
    super
    c.items = [:workspace]
    c.bbar = [:load_some_panel, :load_another_panel, :load_book_explorer, :load_configurable_panel, :load_grid]
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

    [:another_panel, :book_explorer].each do |cmp|
      c.send(:"on_load_#{cmp}=", <<-JS)
        function(){
          this.netzkeGetComponent('workspace').loadInTab("#{cmp.to_s.camelize}", {newTab: true});
        }
      JS
    end

    c.on_load_configurable_panel = <<-JS
      function(){
        this.netzkeGetComponent('workspace').loadInTab("ConfigurablePanel", {newTab: true, config: {update_text: 'HTML from config'}});
      }
    JS

    c.on_load_grid = <<-JS
      function(){
        this.netzkeGetComponent('workspace').loadInTab("BookGridWithColumnActions", {newTab: true, config: {strong_default_attrs: {title: 'Overridden'}}});
      }
    JS
  end
end
