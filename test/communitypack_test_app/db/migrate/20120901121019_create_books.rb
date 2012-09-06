class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.integer :author_id
      t.string :title
      t.integer :exemplars
      t.boolean :digitized, :default => false
      t.text :notes
      t.string :tags
      t.integer :rating
    end
  end
end