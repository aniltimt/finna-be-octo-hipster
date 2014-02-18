class ChangeCustomerPoInOrders < ActiveRecord::Migration
  def self.up
  	change_column :orders, :customer_po, :string
  end

  def self.down
  end
end
