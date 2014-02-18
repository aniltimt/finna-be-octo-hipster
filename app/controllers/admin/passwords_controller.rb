class Admin::PasswordsController < ApplicationController

  before_filter :login_required
  before_filter :check_permissions
  before_filter :get_password, :only => [ :show, :edit, :update, :destroy ]

  verify :method => :post, :only => [ :destroy, :create, :update ],
    :redirect_to => { :action => :index }

  protected

  def check_permissions
    access_control({
        :create =>  ["new", "create"],
        :edit   =>  ["edit", "update"],
        :delete =>  ["destroy"],
        :list   =>  ["index"],
        :view   =>  ["show"]
      })
  end

 public

  # GET /admin/passwords
  def index
    @passwords = Password.paginate :per_page => 18, :page => params[:page]
  end

  # GET /admin/passwords/new
  def new
    @password = Password.new
  end

  # POST /admin/passwords/create
  def create
    @password = Password.new(params[:password])
    if @password.save
      flash[:notice] = "Password was successfully created."
      redirect_to :action => :index
    else
      render :action => "new"
    end
  end

 # POST /admin/passwords/update/1
  def update
    if @password.update_attributes(params[:password])
      flash[:notice] = "Password was successfully updated."
      redirect_to :action => :index
    else
      render :action => :edit
    end
  end

 # POST /admin/passwords/destroy/1
  def destroy
    if @password && @password.destroy
      flash[:notice] = "Password was successfully deleted."
      redirect_to :action => :index
    else
      redirect_to :action => :index
    end
  end

  private

  def get_password
    @password = Password.find_by_id(params[:id])
  end

end