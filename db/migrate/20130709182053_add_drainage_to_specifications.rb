class AddDrainageToSpecifications < ActiveRecord::Migration
  def self.up
    add_column :specifications, :drainage, :boolean
  end

  def self.down
    remove_column :specifications, :drainage
  end
end
