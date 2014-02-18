class AddMissingAttributes < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.string :deposit_invoice
      t.date :deposit_date
      t.decimal :deposit_amount
    end
    change_table :order_product_detail do |t|
      t.string :barcode_number
      t.string :bar_line_one
      t.string :bar_line_two
      t.string :bar_line_three
      t.string :bar_line_four
      t.string :barcode_position
    end
  end

  def self.down
    change_table :orders do |t|
      t.remove :deposit_invoice
      t.remove :deposit_date
    end
    change_table :order_product_detail do |t|
      t.remove :barcode_number
      t.remove :bar_line_one
      t.remove :bar_line_two
      t.remove :bar_line_three
      t.remove :bar_line_four
      t.remove :barcode_position
    end
  end
end
