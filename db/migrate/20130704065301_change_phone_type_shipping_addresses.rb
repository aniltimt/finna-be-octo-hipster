class ChangePhoneTypeShippingAddresses < ActiveRecord::Migration
  def self.up
  	change_column :shipping_addresses, :phone, :string
  	add_column :customers, :oc_code, :string
  	change_column :customers, :add_phone, :string
  	change_column :customers, :fax, :string
  end

  def self.down
  end
end
