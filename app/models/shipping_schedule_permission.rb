class ShippingSchedulePermission < ActiveRecord::Base

  belongs_to :role

  READ_ONLY = 0
  HIDDEN = 1
  EDITABLE = 2

  def get(field)
    if self.attributes.keys.include?(field.to_s)
      self.send(field)
    end
  end

  def editable?(field)
    self.get(field) == EDITABLE
  end

  def visible_fields
    (self.attributes.keys - ['created_at', 'updated_at', 'role_id', 'id']).map {|field| field if self.send(field) != HIDDEN}.delete_if(&:blank?)
  end 
  
  def self.convert_permission(perm)
    if perm == "READ_ONLY"
      perm = READ_ONLY
    elsif perm == "HIDDEN"
      perm = HIDDEN
    elsif perm == "EDITABLE"
      perm = EDITABLE
    elsif perm == READ_ONLY
      perm = "READ_ONLY"
    elsif perm == HIDDEN
      perm = "HIDDEN"
    elsif perm == EDITABLE
      perm = "EDITABLE"
    end
    return perm
  end

end
