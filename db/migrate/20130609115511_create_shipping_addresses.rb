class CreateShippingAddresses < ActiveRecord::Migration
  def self.up
    create_table :shipping_addresses do |t|
      t.integer :customer_id
      t.string :title
      t.string :receiver_name
      t.string :email
      t.integer :phone
      t.text :notes
      t.text :street_1
      t.text :street_2
      t.string :city
      t.string :country
      t.string :province
      t.string :postal_code

      t.timestamps
    end
  end

  def self.down
    drop_table :shipping_addresses
  end
end
