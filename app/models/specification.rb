class Specification < ActiveRecord::Base

  belongs_to :style, :class_name => "::Style"

  named_scope :visible, :conditions => { :visible => true } 

  def before_create
    self.position = self.class.maximum(:position).to_i + 1
  end
  
end
