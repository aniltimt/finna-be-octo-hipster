class Admin::MediaLibraryController < ApplicationController
	before_filter :login_required, :except=>'get_object'
	before_filter :check_permissions, :except=>'get_object'
	
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }	

	# permissions
	protected
	def check_permissions
		access_control({
			:create =>  ["create_folder","create_object"],
			:edit   =>  ["update_folder","update_object","edit_object","browse_media_library","move_items"],
			:delete =>  ["delete_folder","delete_object"],
			:list   =>  ["index", "browse","mini_browse","find"],
			:view   =>  ["get_object","not_found"]
		})
	end  
	public
	# end of permissions   

   uses_tiny_mce(
     :options => {
       :mode => "exact",
       :theme => 'advanced',
       :elements => %w{media_item_content},
       :theme_advanced_buttons1 => %w{bold italic underline strikethrough sub sup separator forecolor backcolor separator justifyleft justifycenter justifyright },
       :theme_advanced_buttons1_add =>%w{formatselect fontselect fontsizeselect},
       :theme_advanced_buttons2 =>%w{bullist numlist separator outdent indent separator undo redo separator link unlink anchor image media cleanup code},
       :theme_advanced_buttons2_add =>%w{separator insertdate inserttime},
       :theme_advanced_buttons2_add_before =>%w{cut copy paste pastetext pasteword separator search replace separator},
       :theme_advanced_buttons3 =>%w{insertlayer moveforward movebackward absolute styleprops},
       :theme_advanced_buttons3_add_before =>%w{tablecontrols separator},
       :theme_advanced_buttons3_add =>%w{emotions advhr separator ltr rtl},
       :theme_advanced_buttons3 =>%w{insertlayer moveforward movebackward absolute styleprops},
       :extended_valid_elements=>%w{hr[class|width|size|noshade] font[face|size|color|style] span[class|align|style]},
        :theme_advanced_toolbar_location => "top",
        :theme_advanced_toolbar_align => "left",
        :theme_advanced_resizing => true,
        :theme_advanced_resize_horizontal => false,
        :file_browser_callback => 'myFileBrowser',
        :relative_urls => false,
       :plugins => %w{style layer table advhr advimage advlink emotions insertdatetime media searchreplace contextmenu directionality inlinepopups}
     },
     :only => [:edit_object]
   )


	def index
		browse
		render :action => 'browse'
	end
	
	def browse
		@parent_id=params[:id] ? params[:id] : "0"
		@parent=MediaHolder.find_by_id(@parent_id)
		@folders=MediaHolder.find(:all, :conditions=>"parent_id=#{@parent_id}",:order=>"name")
		@objects=MediaObject.find(:all, :conditions=>"media_holder_id=#{@parent_id}",:order=>"name")
		if request.xml_http_request?
			render :update do |page|
				page.replace_html "media_objects" , :partial => "media_objects"
			end
		elsif request.post?
			render :action=>"browse"
		end			
	end

	def browse_media_library
		@parent_id=params[:parent_id] ? params[:parent_id] : "0"
		@parent=MediaHolder.find_by_id(@parent_id)
		@folders=MediaHolder.find(:all, :conditions=>"parent_id=#{@parent_id}",:order=>"name")
		@objects=MediaObject.find(:all, :conditions=>"media_holder_id=#{@parent_id}",:order=>"name")
		if request.xml_http_request?
			render :update do |page|
				page.replace_html "media_library" , :partial => "browse_media_library"
			end
		end			
	end	
	
	def mini_browse
		@parent_id=params[:id] ? params[:id] : "0"
		@parent=MediaHolder.find_by_id(@parent_id)
		@folders=MediaHolder.find(:all, :conditions=>"parent_id=#{@parent_id}",:order=>"name")
		@objects=MediaObject.find(:all, :conditions=>"media_holder_id=#{@parent_id}",:order=>"name")
		render :layout=>"mini"
	end	
		
	def create_folder
		MediaHolder.create(params[:media_holder])
		browse			
	end	
	
	def delete_folder
		folder=MediaHolder.find(params[:folder_id])
		clear_folder(folder) 
		folder.destroy
		browse			
	end	
	
	def update_folder
		folder=MediaHolder.find(params[:folder_id])
		folder.update_attributes(params[:media_holder])
		browse			
	end	
			
	def create_object
		object = MediaObject.new(params[:media_object])
		if object.save
			media_type= MediaType.find(params[:media_object][:media_type_id]).codename
			if media_type=="media_file" and !params[:media_file][:file_name].to_s.empty?
				if !File.directory?(MEDIA_FOLDER) # if media folder does not exists
				 Dir.mkdir(MEDIA_FOLDER) # create this folder
				end 			
				file_name=params[:media_file][:file_name].original_filename.gsub(/^.*(\\|\/)/, '')
				file_type=params[:media_file][:file_name].content_type
				file=MediaFile.new(:file_name=>file_name,:file_type=>file_type,:media_object_id=>object.id)
				if file.save
					path=MEDIA_FOLDER + file.id.to_s
					File.open(path, "w") { |f| f.write(params[:media_file][:file_name].read)}	
				end
			elsif media_type=="page"
				Page.create(:media_object_id=>object.id,:template_item_id=>params[:page][:template_item_id], :content=>'')
				redirect_to :action=>"edit_object", :id=>object and return false
			else #create page object by default
				Page.create(:media_object_id=>object.id,:template_item_id=>params[:page][:template_item_id], :content=>'')
				object.update_attribute(:media_type_id,2)
				redirect_to :action=>"edit_object", :id=>object and return false				
			end
		end
		redirect_to :action=>"browse", :id=>params[:id]!="0" ? params[:id] : nil
	end
	
	def delete_object
		object=MediaObject.find(params[:object_id])
		if object.media_type.codename == 'media_file' and object.media_file
			path=MEDIA_FOLDER + object.media_file.id.to_s
			File.delete(path) if File.exists?(path)
		end	
		model = tablify_string(object.media_type.codename)
		media_item = model.find(:first, :conditions => "media_object_id=#{object.id}")
		media_item.destroy
		object.destroy
		browse			
	end	
	
	def update_object
		object=MediaObject.find(params[:object_id])
		object.update_attributes(params[:media_object])
		browse			
	end	
	
	def get_object
		@object = MediaObject.find_by_id(params[:id])
		if @object
			model = tablify_string(@object.media_type.codename)
			@media_item = model.find(:first, :conditions => "media_object_id=#{@object.id}")
			if @object.media_file
				path=MEDIA_FOLDER + @media_item.id.to_s
				send_file(path,{:disposition => 'inline', :type => @media_item.file_type, :filename=>@object.media_file.file_name})
			elsif @object.page
				render :action => :page, :layout=>get_layout_for(@object.page)
			else
				redirect_to :action=>"not_found"
			end
		else
			redirect_to :action=>"not_found"			
		end
	end
	

	def edit_object
		@object = MediaObject.find_by_id(params[:id])
		if @object
			model = tablify_string(@object.media_type.codename)
			@media_item = model.find(:first, :conditions => "media_object_id=#{@object.id}")
			@object.update_attributes(params[:object])
			if @object.media_file
				path=MEDIA_FOLDER + @media_item.id.to_s
				send_file(path,{:disposition => 'inline', :type => @media_item.file_type, :filename=>@object.media_file.file_name})
			elsif @object.page
				if request.post?
					@media_item.update_attributes(params[:media_item])
				end
				render :action => :edit_page#, :layout=>get_layout_for(@object.page)
			else
				redirect_to :action=>"not_found"
			end
		else
			redirect_to :action=>"not_found"			
		end
	end	

	def move_items
		selected_folders=params[:selected_folders].split(',')
		selected_media_objects=params[:selected_media_objects].split(',')
		selected_folders.each do |folder_id|
			MediaHolder.update(folder_id,{:parent_id=>params[:folder_id]}) if !folder_id.empty?	and !get_all_subfolders(folder_id).include?(params[:folder_id].to_i)	
		end		
		selected_media_objects.each do |media_object_id|
			MediaObject.update(media_object_id,{:media_holder_id=>params[:folder_id]}) if !media_object_id.empty?		
		end
		browse		
	end
	
	def find
		params[:search_string]=params[:search_string] ? params[:search_string] : ""
		@folders=!params[:search_string].empty? ? MediaHolder.find(:all, :conditions =>["name LIKE ?", '%' + params[:search_string]+'%' ], :order=>"name") : []
		@objects=!params[:search_string].empty? ? MediaObject.find(:all, :conditions =>["name LIKE ?", '%' + params[:search_string]+'%' ], :order=>"name"): []
	end  						
	
	protected
 
	def clear_folder(folder)
		for child in folder.children		
			clear_folder(child)
			child.destroy
		end
		for object in folder.media_objects
				model = tablify_string(object.media_type.codename)
				media_item = model.find(:first, :conditions => "media_object_id=#{object.id}")
				if object.media_type.codename == 'media_file'
					path=MEDIA_FOLDER + item.id.to_s
					File.delete(path) if File.exists?(path)
				end
				object.destroy
				media_item.destroy
		end
	end
	
	def get_all_subfolders(folder_id)
		sub_folders=[]
		sub_folders+=[folder_id.to_i]
		for sub_folder in MediaHolder.find(folder_id).children		
			sub_folders+=get_all_subfolders(sub_folder.id)
		end	
		sub_folders
	end
  
end
