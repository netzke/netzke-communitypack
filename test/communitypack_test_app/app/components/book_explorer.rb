class BookExplorer < Netzke::Communitypack::ModelExplorer
  def configure(c)
    super
    c.model = "Book"
    c.title = "Book explorer"
  end
end
