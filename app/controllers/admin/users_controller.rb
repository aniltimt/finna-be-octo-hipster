class Admin::UsersController < ApplicationController

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
			:edit   =>  ["edit", "update","enable","disable"],
			:delete =>  ["destroy"],
			:list   =>  ["index", "list"],
			:view   =>  ["show"]
		})
	end  
	public
	# end of permissions
	
	def index
		@users = User.paginate :page => params[:page], :per_page => 18
    render :action => :list
	end

  alias_method :list, :index
		
	def new
		@user = User.new
	end
	
	def create
		@user = User.new(params[:user])
		if @user.save
		  flash[:notice] = 'User was successfully created.'
		  redirect_to :action => 'list'
		else
		  render :action => 'new'
		end
	end
	
	def edit
		@user = User.find(params[:id])
	end
	
	def update
		@user = User.find(params[:id])
		if @user.update_attributes(params[:user])
		  flash[:notice] = 'User was successfully updated.'
		  redirect_to :action => 'edit', :id => @user
		else
		  render :action => 'edit'
		end
	end
	
	def destroy
		User.find(params[:id]).destroy
		redirect_to :action => 'list'
	end
	
	def enable
		@user = User.find(params[:id])
		@user.update_attribute(:enabled,1)		
		redirect_to :action => 'list'
	end
	
	def disable
		@user = User.find(params[:id])
		@user.update_attribute(:enabled,0)
		redirect_to :action => 'list'
	end

end
