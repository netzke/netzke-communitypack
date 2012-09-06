class NodeTreePanelWithEagerLoading < NodeTreePanel
  
  def get_inline_children(r)
    r.children
  end

  def expanded?(r)
    r.children.length > 0
  end

  def leaf?(r)
    !expanded?(r)
  end
end