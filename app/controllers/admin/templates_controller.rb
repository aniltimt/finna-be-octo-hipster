class Admin::TemplatesController < ApplicationController

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
		@template_items = TemplateItem.paginate :page => params[:page], :per_page => 18
		render :action => 'list'
	end

  alias_method :list, :index
		
	def new
		@template_item = TemplateItem.new
	end
	
	def create
		@template_item = TemplateItem.new(params[:template_item])
		if @template_item.save
		  flash[:notice] = 'Template item was successfully created.'
		  redirect_to :action => 'list'
		else
		  render :action => 'new'
		end
	end
	
	def edit
		@template_item = TemplateItem.find_by_id(params[:id])
	end
	
	def update
		@template_item = TemplateItem.find(params[:id])
		if @template_item.update_attributes(params[:template_item])
		  flash[:notice] = 'Template item was successfully updated.'
		  redirect_to :action => 'edit', :id => @template_item
		else
		  render :action => 'edit'
		end
	end
	
	def destroy
		TemplateItem.find(params[:id]).destroy
		redirect_to :action => 'list'
	end

end
