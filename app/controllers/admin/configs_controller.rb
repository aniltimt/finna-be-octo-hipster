class Admin::ConfigsController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }	

  protected

    # permissions
    def check_permissions
      access_control({
        :create =>  ["new", "create", "refresh_config"],
        :edit   =>  ["edit", "update", "refresh_config"],
        :delete =>  ["destroy"],
        :list   =>  ["index", "list"],
        :view   =>  ["show"]
      })
    end  
    # end of permissions
    
  public

  def index
    @app_configs = AppConfig.paginate :page => params[:page], :per_page => 18
    render :action => :list
  end

  alias_method :list, :index

  def show
    @app_config = AppConfig.find(params[:id])
  end

  def new
    @app_config = AppConfig.new
  end

  def create
    @app_config = AppConfig.new(params[:app_config])
    if @app_config.save
      flash[:notice] = 'Configuration was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @app_config = AppConfig.find(params[:id])
  end

  def update
    @app_config = AppConfig.find(params[:id])
    if @app_config.update_attributes(params[:app_config])
      flash[:notice] = 'Configuration was successfully updated.'
      redirect_to :action => 'edit', :id => @app_config
    else
      render :action => 'edit'
    end
  end

  def refresh_config
    @app_config = AppConfig.find_by_key('host_name')
    if @app_config
      @app_config.value = request.host()
    else
      @app_config = AppConfig.new
      @app_config.key = 'host_name'
      @app_config.value = request.host()
    end
    if @app_config.save
      flash[:notice] = 'host_name was successfully updated.'
      redirect_to :action => 'list'
    end
  end
  
  def destroy
    AppConfig.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

end
