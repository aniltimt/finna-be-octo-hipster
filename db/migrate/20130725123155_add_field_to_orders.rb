class AddFieldToOrders < ActiveRecord::Migration
  def self.up
  	add_column :orders, :finished_date, :date
  end

  def self.down
  	remove_column :orders, :finished_date
  end
end
