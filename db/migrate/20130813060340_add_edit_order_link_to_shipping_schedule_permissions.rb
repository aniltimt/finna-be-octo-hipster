class AddEditOrderLinkToShippingSchedulePermissions < ActiveRecord::Migration
  def self.up
    add_column :shipping_schedule_permissions, :edit_order_link, :string
  end

  def self.down
  end
end
