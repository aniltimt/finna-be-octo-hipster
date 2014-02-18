class AddFinishedDateToShippingSchedulePermissions < ActiveRecord::Migration
  def self.up
    add_column :shipping_schedule_permissions, :finished_date, :int
  end

  def self.down
  end
end
