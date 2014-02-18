class AddCustomerPoToShippingSchedulePermissions < ActiveRecord::Migration
  def self.up
    add_column :shipping_schedule_permissions, :customer_po, :integer, :default => "0", :null => false
  end

  def self.down
  end
end
