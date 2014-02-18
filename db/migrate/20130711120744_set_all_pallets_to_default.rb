class SetAllPalletsToDefault < ActiveRecord::Migration
  def self.up
    Style.all.each do |s|
      s.palette.destroy
      s.save
    end
  end

  def self.down
  end
end
