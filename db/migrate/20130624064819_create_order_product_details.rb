class CreateOrderProductDetails < ActiveRecord::Migration
  def self.up
    create_table :order_product_details do |t|
      t.integer :order_id
      t.string  :code
      t.string  :description
      t.string  :colour
      t.string  :notes
      t.boolean :drainage
      t.integer :skid
      t.integer :pack
      t.integer :total
      t.integer :price
      t.integer :total_amount
      t.integer :barcode_number
      t.integer :bar_line_one
      t.integer :bar_line_two
      t.integer :bar_line_three
      t.integer :bar_line_four
      t.string  :barcode_position

      t.timestamps
    end
  end

  def self.down
    drop_table :order_product_details
  end
end
