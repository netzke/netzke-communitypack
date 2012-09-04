class BookGridWithLiveSearch < Netzke::Communitypack::LiveSearchGridPanel
  
  def configure(c)
    c.model = "Book"
    c.title = I18n.t('books', :default => "Books")
    c.live_search_scope 
    c.columns = [:title]
    super
  end
  
end