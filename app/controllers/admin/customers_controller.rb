class Admin::CustomersController < ApplicationController
  before_filter :login_required 
  # GET /customers
  # GET /customers.xml
  def index
    @conditions = ''
    if !params[:company].blank?
      str = '%'+params[:company]+'%'
      @conditions << " company LIKE '#{str}' "
    end
    if !params[:customer_name].blank?
      str = '%'+params[:customer_name]+'%'
      if @conditions.blank?
        @conditions << " customer_name LIKE '#{str}' "
      else
        @conditions << " and customer_name LIKE '#{str}' "
      end
    end
    if !params[:region].blank?
      str = '%'+params[:region]+'%'
      if @conditions.blank?
        @conditions << " region LIKE '#{str}' "
      else
        @conditions << " and region LIKE '#{str}' "
      end
    end
    if !params[:commit].blank?
      @customers = Customer.paginate :page => params[:page], :per_page => 18, :conditions => @conditions
    else
      @customers = []
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @customers }
    end
  end

  # GET /customers/1
  # GET /customers/1.xml
  def show
    @customer = Customer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/new
  # GET /customers/new.xml
  def new
    @customer = Customer.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @customer }
    end
  end

  # GET /customers/1/edit
  def edit
    @customer = Customer.find(params[:id])
  end

  # POST /customers
  # POST /customers.xml
  def create
    @customer = Customer.new(params[:customer])

    respond_to do |format|
      if @customer.save
        flash[:notice] = 'Customer was successfully created'
        format.html { redirect_to :action => "show", :id => @customer.id }
        format.xml  { render :xml => @customer, :status => :created, :location => @customer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customers/1
  # PUT /customers/1.xml
  def update
    @customer = Customer.find(params[:id])

    respond_to do |format|
      if @customer.update_attributes(params[:customer])
        flash[:notice] = 'Customer was successfully updated'
        format.html { redirect_to :action => "show", :id => @customer.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @customer.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1
  # DELETE /customers/1.xml
  def destroy
    @customer = Customer.find(params[:id])
    @customer.destroy

    respond_to do |format|
      format.html { redirect_to(customers_url) }
      format.xml  { head :ok }
    end
  end

  def province_dropdown
    @province = params[:country]
    @customer = Customer.find(params[:selected_customer_id]) if !params[:selected_customer_id].blank?
    render :layout => false
  end
end
