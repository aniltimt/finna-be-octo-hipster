class Admin::NavigationController < ApplicationController
	before_filter :login_required, :except => ['get_image']
	before_filter :check_permissions, :except => ['get_image']
  
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :list }
		 
	# permissions
	protected
	def check_permissions
		access_control({
        :create=> ["new", "create","browse_media_library","browse_navigation_items"],
        :edit=>	["edit", "update","enable","disable", "update_positions","browse"],
        :delete=> ["destroy", 'delete_image'],			
        :list=>	["index", "list"],
        :view=>	["show"]		
      })
	end

  def delete_image_files(id,path)
    paths = path + "#{id.to_s}_default"
    if File.exists?(paths)
      File.delete(paths)
    end
    paths = path + "#{id.to_s}_hover"
    if File.exists?(paths)
      File.delete(paths)
    end
    paths = path + "#{id.to_s}_navigation"
    if File.exists?(paths)
      File.delete(paths)
    end   
  end
  
	public
	# end of permissions
		 
	def index
		list
		render :action => 'list'
	end
		
	def list
		@navigation_items = NavigationItem.find(:all,:conditions=>"parent_id=0",:order=>"position")
	end
		
	def new
		if params[:id]
			parent_id=params[:id]
			parent=NavigationItem.find(parent_id)
			@navigation_item_url= parent.url+'/'		
		else
			parent_id=0
			@navigation_item_url='/'
		end
		@navigation_item = NavigationItem.new(:parent_id=>parent_id,:url=>@navigation_item_url)
	end
	
	def create
		@navigation_item = NavigationItem.new(params[:navigation_item])
		if @navigation_item.save
      if !params[:file][:default_image].to_s.empty?
        if !File.directory?(NavigationItem.file_path) 
          Dir.mkdir(NavigationItem.file_path)
        end
        filename = params[:file][:default_image].original_filename.gsub(/^.*(\\|\/)/, '')
        path = NavigationItem.file_path + @navigation_item.id.to_s + '_default'
        if (File.open(path, "wb") { |f| f.write(params[:file][:default_image].read)})
          @navigation_item.update_attributes(:default_image => filename)
        end
      end
      if !params[:file][:hover_image].to_s.empty?
        if !File.directory?(NavigationItem.file_path) 
          Dir.mkdir(NavigationItem.file_path)
        end
        filename = params[:file][:hover_image].original_filename.gsub(/^.*(\\|\/)/, '')
        path = NavigationItem.file_path + @navigation_item.id.to_s + '_hover'
        if (File.open(path, "wb") { |f| f.write(params[:file][:hover_image].read)})
          @navigation_item.update_attributes(:hover_image => filename)
        end
      end
      if !params[:file][:current_image].to_s.empty?
        if !File.directory?(NavigationItem.file_path) 
          Dir.mkdir(NavigationItem.file_path)
        end
        filename = params[:file][:current_image].original_filename.gsub(/^.*(\\|\/)/, '')
        path = NavigationItem.file_path + @navigation_item.id.to_s + '_current'
        if (File.open(path, "wb") { |f| f.write(params[:file][:current_image].read)})
          @navigation_item.update_attributes(:current_image => filename)
        end
      end
		  flash[:notice] = 'Navigation item was successfully created.'
		  redirect_to :action => 'list'
		else
		  render :action => 'new'
		end
	end
	
	def edit
		@navigation_item = NavigationItem.find(params[:id])
		@navigation_item_url= @navigation_item.parent ?  @navigation_item.parent.url+'/' : '/'
	end
	
	def update
		@navigation_item = NavigationItem.find(params[:id])
		if @navigation_item.update_attributes(params[:navigation_item])
      if !params[:file][:default_image].to_s.empty?
        if !File.directory?(NavigationItem.file_path) 
          Dir.mkdir(NavigationItem.file_path)
        end
        filename = params[:file][:default_image].original_filename.gsub(/^.*(\\|\/)/, '')
        path = NavigationItem.file_path + @navigation_item.id.to_s + '_default'
        if (File.open(path, "wb") { |f| f.write(params[:file][:default_image].read)})
          @navigation_item.update_attributes(:default_image => filename)
        end
      end
      if !params[:file][:hover_image].to_s.empty?
        if !File.directory?(NavigationItem.file_path) 
          Dir.mkdir(NavigationItem.file_path)
        end
        filename = params[:file][:hover_image].original_filename.gsub(/^.*(\\|\/)/, '')
        path = NavigationItem.file_path + @navigation_item.id.to_s + '_hover'
        if (File.open(path, "wb") { |f| f.write(params[:file][:hover_image].read)})
          @navigation_item.update_attributes(:hover_image => filename)
        end
      end
      if !params[:file][:current_image].to_s.empty?
        if !File.directory?(NavigationItem.file_path) 
          Dir.mkdir(NavigationItem.file_path)
        end
        filename = params[:file][:current_image].original_filename.gsub(/^.*(\\|\/)/, '')
        path = NavigationItem.file_path + @navigation_item.id.to_s + '_current'
        if (File.open(path, "wb") { |f| f.write(params[:file][:current_image].read)})
          @navigation_item.update_attributes(:current_image => filename)
        end
      end
		  flash[:notice] = 'Navigation item was successfully updated.'
		  redirect_to :action => 'edit', :id => @navigation_item
		else
		  render :action => 'edit'
		end
	end
	
	def destroy
		NavigationItem.find(params[:id]).destroy
		delete_image_files(params[:id], NavigationItem.file_path )
    redirect_to :action => 'list'
	end
	
	def enable
		@navigation_item = NavigationItem.find(params[:id])
		@navigation_item.update_attribute(:enabled,1)		
		redirect_to :action => 'list'
	end
	
	def disable
		@navigation_item = NavigationItem.find(params[:id])
		@navigation_item.update_attribute(:enabled,0)
		redirect_to :action => 'list'
	end	
	
	def update_positions
		if params["navigation_items_"+params[:parent_id]]
		  params["navigation_items_"+params[:parent_id]].each_with_index do |id, position|
        NavigationItem.update(id, :position => position)
		  end		
		end
		@navigation_items = NavigationItem.find(:all,:conditions=>"parent_id=#{params[:parent_id]}",:order=>"position")
    if params[:parent_id]=='0' and request.xml_http_request?
      render :update do |page|
        page.replace_html "navigation_items_holder_#{params[:parent_id]}",:partial=>"navigation_items_holder", :locals=>{:parent_id=>params[:parent_id],:navigation_items=>@navigation_items}
      end
		else
			render :nothing=>true
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
	
	def browse_navigation_items
		@navigation_item = NavigationItem.find(params[:id]) if params[:id]!="0"	
		@navigation_items = NavigationItem.find(:all,:conditions=>["parent_id=0 and id!=?",@navigation_item ? @navigation_item.id : 0],:order=>"position")
		if request.xml_http_request?
			render :update do |page|
				page.replace_html "navigation_items" , :partial => "browse_navigation_items"
			end
		end			
	end
  
  def get_image
    navigation_item=NavigationItem.find(params[:id])
    type=params[:type]
    path=NavigationItem.file_path+navigation_item.id.to_s+'_'+type
    if File.exists?(path)
      send_file(path,{:disposition => 'inline', :type => 'image/gif', :filename => eval("navigation_item.#{type}_image")})
    end
  end
  
  def delete_image
    navigation_item=NavigationItem.find(params[:id])
    type=params[:type]
    path=NavigationItem.file_path+navigation_item.id.to_s+'_'+type
    if File.exists?(path)
      File.delete(path)
    end
    @navigation_item.update_attribute(type + '_image', '')
    render :nothing =>true
  end
  
end
