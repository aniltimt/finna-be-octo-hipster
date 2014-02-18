class MediaHolder < ActiveRecord::Base

  acts_as_tree :order => "name"
  has_many :media_objects
  
end
