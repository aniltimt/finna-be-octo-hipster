class CreateShippingSchedulePermissions < ActiveRecord::Migration
  def self.up
    create_table :shipping_schedule_permissions do |t|
      t.integer :role_id
      t.integer :reference
      t.integer :date_created
      t.integer :status
      t.integer :customer_name
      t.integer :order_confirmation
      t.integer :requested_ship_date
      t.integer :requested_delivery
      t.integer :mixed_full
      t.integer :arrival_port
      t.integer :customer_city
      t.integer :confirmed_ship_date
      t.integer :eta_to_port
      t.integer :eta_to_customer
      t.integer :shipping_notes

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_schedule_permissions
  end
end
