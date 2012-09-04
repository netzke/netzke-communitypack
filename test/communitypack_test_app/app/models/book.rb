class Book < ActiveRecord::Base
  validates_presence_of :title
  attr_accessible :title

  scope :live_search, lambda { |title| where("title LIKE ?", "#{title}%") }
end

# TODO: Add support for Sequel and DataMapper