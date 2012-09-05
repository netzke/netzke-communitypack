class AuthorTreePanel < Netzke::Communitypack::TreePanel
  
  def configure(c)
    c.model = "Author"
    c.columns = [{:name => 'name', :getter => lambda{|r| title(r)}, :width => 300}, :first_name, :last_name]
    c.treecolumn = :name
    c.pri = :class_plus_id
    super
  end

  # Retrieves all children for a node
  #
  # @param [Hash] params
  # @return [Array] array of records
  def get_children(params)
    if params[:id].nil? || params[:id] == 'root' 
      super # Let the data_class handle the root collection
    else params[:id] =~ /Author-(\d+)/
      Book.where(:author_id => $1)
    end
  end

  # Get the title of a record
  def title(r)
    if r.is_a?(Author)
      r.name
    else
      r.title
    end
  end

  # Leaf or not?
  def leaf?(r)
    r.is_a?(Book)
  end

  # Unique identifier for a record
  def class_plus_id(r)
    "#{r.class}-#{r.id}"
  end
end