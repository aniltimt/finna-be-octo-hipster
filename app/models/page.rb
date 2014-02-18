class Page < ActiveRecord::Base

	belongs_to :media_object
	belongs_to :template_item
  
end
