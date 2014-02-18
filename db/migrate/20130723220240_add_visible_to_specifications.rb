class AddVisibleToSpecifications < ActiveRecord::Migration
  def self.up
    add_column :specifications, :visible, :boolean, :default => true
  end

  def self.down
    remove_column :specifications, :visible
  end
end
