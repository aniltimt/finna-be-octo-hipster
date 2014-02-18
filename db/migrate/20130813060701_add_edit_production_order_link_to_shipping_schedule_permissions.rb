class AddEditProductionOrderLinkToShippingSchedulePermissions < ActiveRecord::Migration
  def self.up
    add_column :shipping_schedule_permissions, :edit_production_order_link, :string
  end

  def self.down
  end
end
