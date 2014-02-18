class AddShipChargeOrders < ActiveRecord::Migration
  def self.up
  	add_column :orders, :add_ship_charge, :integer
  end

  def self.down
  end
end
