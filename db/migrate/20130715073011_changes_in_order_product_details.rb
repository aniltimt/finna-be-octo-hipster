class ChangesInOrderProductDetails < ActiveRecord::Migration
  def self.up
  	add_column :orders, :final_amount, :float
  	remove_column :order_product_details, :final_amount
  end

  def self.down
  end
end
