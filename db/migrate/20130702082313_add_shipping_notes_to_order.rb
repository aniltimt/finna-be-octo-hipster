class AddShippingNotesToOrder < ActiveRecord::Migration
  def self.up
    add_column :orders, :shipping_notes, :string
  end

  def self.down
    remove_column :orders, :shipping_notes
  end
end
