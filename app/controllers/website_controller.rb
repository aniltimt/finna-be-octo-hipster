class WebsiteController < ApplicationController

	layout 'default'

	def show_page
		if params[:url]
			@navigation_item = NavigationItem.first(:conditions => ["url = ? AND enabled = 1", "/#{params[:url]}"])
			@object = (@navigation_item && @navigation_item.media_object_id != 0) ? @navigation_item.media_object : nil
		else
			@object = MediaObject.find(params[:id])
		end

		if @object
			model = tablify_string(@object.media_type.codename)
			@media_item = model.first(:conditions => "media_object_id = #{@object.id}")
			if @object.media_file
				path = MEDIA_FOLDER + @media_item.id.to_s
				send_file(path, {:disposition => 'inline', :type => @media_item.file_type, :filename => @object.media_file.file_name})
			elsif @object.page
				render :action => :page, :layout => get_layout_for(@object.page)
			else
				render :action => "page_not_found", :status => "404 Not Found"
			end
		else
			render :action => "page_not_found", :status => "404 Not Found"
		end		
	end

end