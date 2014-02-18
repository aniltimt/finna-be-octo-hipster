module Admin::MediaLibraryHelper
	def yah(object)
		yah_links = object.name
		while object.parent_id!=0 do 
			object = MediaHolder.find(object.parent_id)
			yah_links = link_to(object.name, :action=>'browse', :id=>object.id) +" > #{yah_links}"
		end	
		yah_links = link_to("Media Library", :action=>'browse', :id=>nil) +" > #{yah_links}"	
		return content_tag("div", yah_links,:class=>"yah")
	end
end
