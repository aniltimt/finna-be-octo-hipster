class ChangeFieldsToOrders < ActiveRecord::Migration
  def self.up
  	change_column :order_product_details, :price, :float
  	change_column :order_product_details, :total_amount, :float
  	add_column :order_product_details, :final_amount, :float
  end

  def self.down
  end
end
