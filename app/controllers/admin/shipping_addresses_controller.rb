class Admin::ShippingAddressesController < ApplicationController
  before_filter :login_required #, :except => ["get_gallery_image","get_style_image","get_image"]
  #before_filter :check_permissions, :except => ["get_gallery_image","get_style_image","get_image"]

  # GET /shipping_addresses
  # GET /shipping_addresses.xml
  def index
    @shipping_addresses = ShippingAddress.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @shipping_addresses }
    end
  end

  # GET /shipping_addresses/1
  # GET /shipping_addresses/1.xml
  def show
    @shipping_address = ShippingAddress.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @shipping_address }
    end
  end

  # GET /shipping_addresses/new
  # GET /shipping_addresses/new.xml
  def new
    @shipping_address = ShippingAddress.new(:customer_id=>params[:id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shipping_address }
    end
  end

  # GET /shipping_addresses/1/edit
  def edit
    @shipping_address = ShippingAddress.find(params[:id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @shipping_address }
    end
  end

  # POST /shipping_addresses
  # POST /shipping_addresses.xml
  def create
    @shipping_address = ShippingAddress.new(params[:shipping_address])

    respond_to do |format|
      if @shipping_address.save
        @customer = @shipping_address.customer
        flash[:notice] = 'Shipping Address was successfully created.'
        format.html { redirect_to :controller => "admin/customers",:action => "edit",:id => @customer.id }
        format.xml  { render :xml => @shipping_address, :status => :created, :location => @shipping_address }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @shipping_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /shipping_addresses/1
  # PUT /shipping_addresses/1.xml
  def update
    @shipping_address = ShippingAddress.find(params[:id])

    respond_to do |format|
      if @shipping_address.update_attributes(params[:shipping_address])
        @customer = @shipping_address.customer
        flash[:notice] = 'Shipping Address was successfully updated.'
        format.html { redirect_to :controller => "admin/customers",:action => "edit",:id => @customer.id }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @shipping_address.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_addresses/1
  # DELETE /shipping_addresses/1.xml
  def destroy
    @shipping_address = ShippingAddress.find(params[:id])
    @shipping_address.destroy

    respond_to do |format|
      format.html { redirect_to(shipping_addresses_url) }
      format.xml  { head :ok }
    end
  end

  def shipping_province_dropdown
    @province = params[:country]
    @shipping_address = ShippingAddress.find(params[:shipping_address_id]) if !params[:shipping_address_id].blank?
    render :layout => false
  end
end
