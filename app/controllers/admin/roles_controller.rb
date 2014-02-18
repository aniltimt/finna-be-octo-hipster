class Admin::RolesController < ApplicationController
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
                     :edit   =>  ["edit", "update","add_permission","del_permission"],
                     :delete =>  ["destroy"],
                     :list   =>  ["index", "list"],
                     :view   =>  ["show"]
                   })
  end  
  public
  # end of permissions
  
  def index
    @roles = Role.paginate :page => params[:page], :per_page => 18
    render :action => 'list'		
  end
  
  alias_method :list, :index
  
  def show
    @role = Role.find(params[:id])
  end
  
  def new
    @role = Role.new
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to :action => 'edit', :id => @role
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
    #Paginate permissions in role/edit view - see admin role..
    unless @role.permissions.empty?
      @role_permissions = @role.permissions.paginate :page => params[:page], :per_page => 5
    end
    #For defining filters.
    @customers = [''] + Customer.all.map { |c| [c.customer_name, c.id] }
  end

  def update
    @role = Role.find(params[:id])
    update_permissions
    update_filters
    if @role.update_attributes(params[:role])
      flash[:notice] = 'Role was successfully updated.'
      redirect_to :action => 'edit', :id => @role
    else
      render :action => 'edit'
    end
  end

  def destroy
    Role.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def add_permission
    @role = Role.find(params[:id])
    @permission = Permission.find(params[:permission][:id])
    @role.add_permission(@permission)
    flash[:notice] = 'Permission was successfully added.'
    redirect_to :action => 'edit', :id => @role
  end
  
  def del_permission
    @role = Role.find(params[:id])	
    @permission = Permission.find(params[:permission][:id])
    @role.remove_permission(@permission)
    flash[:notice] = 'Permission was successfully removed.'
    redirect_to :action => 'edit', :id => @role
  end
  
  private
  def update_filters
    ssf = ShippingScheduleFilter.find(:first, :conditions => ["role_id = ?", params[:id]])
    ssf = ShippingScheduleFilter.new(:role_id => params[:id]) unless ssf
    ssf.eta_to_port_after = params[:filters][:eta_to_port_after]
    ssf.confirmed_shipdate_after = params[:filters][:confirmed_shipdate_after]
    ssf.status = params[:filters][:status]
    ssf.customer_id = params[:filters][:customer_id]
    ssf.reference = params[:filters][:reference]
    ssf.mixed_full = params[:filters][:mixed_full]
    ssf.reference_no_blanks = params[:filters][:reference_no_blanks]
    ssf.eta_to_port_after_no_blanks = params[:filters][:eta_to_port_after_no_blanks]
    ssf.confirmed_shipdate_after_no_blanks = params[:filters][:confirmed_shipdate_after_no_blanks]
    ssf.save
  end
  def update_permissions
    params[:shipping_schedule_permissions].each do |field|
      perm = ShippingSchedulePermission.convert_permission(field[1])
      params[:shipping_schedule_permissions][field[0].to_sym] = perm
    end
    ssp = ShippingSchedulePermission.find(:first, :conditions => ["role_id = ?", params[:id]])
    ssp = ShippingSchedulePermission.new(:role_id => params[:id]) unless ssp
    ssp.update_attributes(
                          :status => params[:shipping_schedule_permissions][:status],
                          :order_confirmation => params[:shipping_schedule_permissions][:order_confirmation],
                          :customer_name => params[:shipping_schedule_permissions][:customer_name],
                          :edit_order_link => params[:shipping_schedule_permissions][:edit_order_link],
                          :edit_production_order_link => params[:shipping_schedule_permissions][:edit_production_order_link],
                          :arrival_port => params[:shipping_schedule_permissions][:arrival_port],
                          :eta_to_customer => params[:shipping_schedule_permissions][:eta_to_customer],
                          :eta_to_port => params[:shipping_schedule_permissions][:eta_to_port],
                          :reference => params[:shipping_schedule_permissions][:reference],
                          :customer_po => params[:shipping_schedule_permissions][:customer_po],
                          :customer_city => params[:shipping_schedule_permissions][:customer_city],
                          :confirmed_ship_date => params[:shipping_schedule_permissions][:confirmed_ship_date],
                          :requested_delivery => params[:shipping_schedule_permissions][:requested_delivery],
                          :requested_ship_date => params[:shipping_schedule_permissions][:requested_ship_date],
                          :finished_date => params[:shipping_schedule_permissions][:finished_date],
                          :date_created => params[:shipping_schedule_permissions][:date_created],
                          :mixed_full => params[:shipping_schedule_permissions][:mixed_full]
                          )
  end

end
