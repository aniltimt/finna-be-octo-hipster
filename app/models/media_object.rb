class MediaObject < ActiveRecord::Base
  
	belongs_to :media_type
	belongs_to :media_holder
	has_one :media_file	
	has_one :page
	has_one :navigation_item, :dependent=>:nullify
	
end
