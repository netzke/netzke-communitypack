class Node < ActiveRecord::Base
  attr_accessible :parent_id, :title

  belongs_to :parent, :class_name => 'Node'
  has_many :children, :foreign_key => 'parent_id', :class_name => 'Node'
end
