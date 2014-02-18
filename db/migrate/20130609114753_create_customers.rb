class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :customer_name
      t.string :user_name
      t.string :company
      t.string :region
      t.string :currency
      t.string :customer_status
      t.string :password
      t.string :arrival_port
      t.string :terms
      t.string :delivery_terms
      t.string :contact_name
      t.string :phone
      t.string :position
      t.string :email
      
      t.integer :add_phone
      t.integer :fax
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
    drop_table :customers
  end
end
