class Book < ActiveRecord::Base
  validates_presence_of :title
  attr_accessible :title
  belongs_to :author

  scope :live_search, lambda { |title| where("title LIKE ?", "#{title}%") }
end

# TODO: Add support for Sequel and DataMapper