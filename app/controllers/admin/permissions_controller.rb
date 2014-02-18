class Admin::PermissionsController < ApplicationController
	before_filter :login_required 
	before_filter :check_permissions
  
	# GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
	verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
		 
	# permissions
	protected
	def check_permissions
		access_control({
			:create =>  ["new", "create"],
			:edit   =>  ["edit", "update"],
			:delete =>  ["destroy"],
			:list   =>  ["index", "list"],
			:view   =>  ["show"]
		})
	end  
	public
	# end of permissions
		 
	def index
		@permissions = Permission.paginate :page => params[:page], :per_page => 18, :order=>"name"
		render :action => 'list'
	end

  alias_method :list, :index
		
	def new
		@permission = Permission.new
	end
	
	def create
		@permission = Permission.new(params[:permission])
		if @permission.save
		  flash[:notice] = 'Permission was successfully created.'
		  redirect_to :action => 'list'
		else
		  render :action => 'new'
		end
	end
	
	def edit
		@permission = Permission.find(params[:id])
	end
	
	def update
		@permission = Permission.find(params[:id])
		if @permission.update_attributes(params[:permission])
		  flash[:notice] = 'Permission was successfully updated.'
		  redirect_to :action => 'edit', :id => @permission
		else
		  render :action => 'edit'
		end
	end
	
	def destroy
		Permission.find(params[:id]).destroy
		redirect_to :action => 'list'
	end

end
