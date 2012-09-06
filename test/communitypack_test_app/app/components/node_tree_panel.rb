class NodeTreePanel < Netzke::Communitypack::TreePanel
  
  def configure(c)
    c.model = "Node"
    c.columns = [:title]
    c.treecolumn = :title
    c.parent_key = :parent_id
    super
  end

  # Is a node a leaf or not?
  #
  # @param [Object] r
  # @return [Boolean]
  def leaf?(r)
    if @has_children_map.nil?
      @has_children_map = {}
      # Use @records of the current request to speed up further request of this method
      Node.where(:parent_id => @records.map(&:id)).select(:parent_id).each do |n|
        @has_children_map[n.parent_id] = true
      end
    end
    !@has_children_map[r.id]
  end
end