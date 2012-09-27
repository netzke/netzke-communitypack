class BookExplorer < Netzke::Communitypack::ModelExplorer
  def configure(c)
    super
    c.model = "Book"
  end
end
