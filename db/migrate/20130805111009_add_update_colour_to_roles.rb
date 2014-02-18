class AddUpdateColourToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :update_colour, :string, :default => "#FFFFFF", :null => false
  end

  def self.down
  end
end
