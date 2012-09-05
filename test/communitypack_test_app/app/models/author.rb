class Author < ActiveRecord::Base
  attr_accessible :first_name, :last_name

  has_many :books

  # virtual attribute
  def name
    "#{last_name}, #{first_name}"
  end
end
