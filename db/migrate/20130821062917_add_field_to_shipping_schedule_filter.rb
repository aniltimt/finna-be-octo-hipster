class AddFieldToShippingScheduleFilter < ActiveRecord::Migration
  def self.up
    add_column :shipping_schedule_filters, :eta_to_port_after_no_blanks, :boolean
    add_column :shipping_schedule_filters, :confirmed_shipdate_after_no_blanks, :boolean
    add_column :shipping_schedule_filters, :reference_no_blanks, :boolean
  end

  def self.down
    remove_column :shipping_schedule_filters, :eta_to_port_after_no_blanks, :boolean
    remove_column :shipping_schedule_filters, :confirmed_shipdate_after_no_blanks, :boolean
    remove_column :shipping_schedule_filters, :reference_no_blanks, :boolean
  end
end
