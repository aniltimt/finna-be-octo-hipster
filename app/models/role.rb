class Role < ActiveRecord::Base

  has_and_belongs_to_many :permissions, :order => 'name'
  has_many :users
  has_one :shipping_schedule_permission
  has_one :shipping_schedule_filter

  def add_permission(permission)
    self.permissions << permission unless self.permissions.include? permission
  end

  def remove_permission(permission)
    self.permissions.delete(permission) if self.permissions.include? permission
  end
end
