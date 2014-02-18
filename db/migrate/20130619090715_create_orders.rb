class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :customer_id
      t.string  :company
      t.integer :shipping_address_id
      t.integer :customer_po
      t.text    :sold_to
      t.string :sold_by
      t.date   :requested_delivery 
      t.date   :requested_ship_date 
      t.date   :confirmed_ship_date 
      t.date   :eta_to_port 
      t.date   :eta_to_customer 
      t.date   :date_created
      t.string :order_confirmation
      t.string :status
      t.text   :ship_to
      t.string :arrival_port
      t.string :terms
      t.string :delivery_terms 
      t.string :mixed_full
      t.text   :notes
      t.string :currency
      t.string :reference
      t.string :deposit_invoice
      t.date :deposit_date
      t.string :deposit_amount

      t.timestamps
    end
  end

  def self.down
    drop_table :orders
  end
end
