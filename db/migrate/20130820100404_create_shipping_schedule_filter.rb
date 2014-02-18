class CreateShippingScheduleFilter < ActiveRecord::Migration
  def self.up
    create_table :shipping_schedule_filters do |t|
      t.integer :role_id
      t.string :eta_to_port_after
      t.string :confirmed_shipdate_after
      t.integer :status
      t.integer :customer_id
      t.string :reference
      t.integer :mixed_full
      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_schedule_filters
  end
end
