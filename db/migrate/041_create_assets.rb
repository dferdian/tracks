class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.integer :parent_id
      t.string :filename
      t.string :content_type
      t.integer :size
      t.integer :height
      t.integer :width
      t.string :thumbnail
      t.integer :contentasset_id
      t.string :contentasset_type
	  
      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
