class AddImagesToStyles < ActiveRecord::Migration
  def self.up
    change_table :styles do |t|
      t.string :image2_file_name
      t.string :image2_content_type
      t.integer :image2_file_size
      t.datetime :image2_updated_at
      t.string :image3_file_name
      t.string :image3_content_type
      t.integer :image3_file_size
      t.datetime :image3_updated_at
    end
  end

  def self.down
    change_table :styles do |t|
      t.remove :image2_file_name
      t.remove :image2_content_type
      t.remove :image2_file_size
      t.remove :image2_updated_at
      t.remove :image3_file_name
      t.remove :image3_content_type
      t.remove :image3_file_size
      t.remove :image3_updated_at
    end
  end
end
