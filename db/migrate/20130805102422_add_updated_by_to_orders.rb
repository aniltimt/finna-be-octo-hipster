class AddUpdatedByToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :updated_by, :int, :default => 1, :null => false
  end

  def self.down
  end
end
