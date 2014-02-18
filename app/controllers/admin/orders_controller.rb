class Admin::OrdersController < ApplicationController
  before_filter :login_required #, :except => ["get_gallery_image","get_style_image","get_image"]
  #before_filter :check_permissions, :except => ["get_gallery_image","get_style_image","get_image"]
  after_filter :update_full_refs_and_ocs, :only => [:create, :update]
  # GET /orders
  # GET /orders.xml
  def update_all
    @orders = Order.find(:all)
    @orders.each do |order|
       #Full OC
      if (!order.customer.blank?  && !order.customer.oc_code.blank?) 
        oc_code = (order.customer.oc_code).upcase
      else
        oc_code = ""
      end
      full_oc = order.company+"O-"+oc_code+" "+order.order_confirmation
      #Full Reference
      if (order.company == "C")
        full_ref = "CTI-"+order.reference
      else
        full_ref = "CENT-"+order.reference
      end
      order.update_attributes(:order_confirmation => full_oc, :reference => full_ref)
    end
    redirect_to :action => "index"
  end
  
  def index
    @customers = Customer.all
    @address = ShippingAddress.all
    @orders = Order.paginate :page => params[:page], :per_page => 12, :order=>"created_at DESC"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.xml
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml =>  @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.xml
  def new
    if !params[:customer_id].blank? || !params[:shipping_address_id].blank?
      @customer = Customer.find(params[:customer_id])
      @address = ShippingAddress.find(params[:shipping_address_id])
      @order = Order.new(:customer_id=>params[:customer_id],
        :company=>params[:company],:status => "Pending",
        :shipping_address_id=>params[:shipping_address_id])

      respond_to do |format|
        if @customer.blank? || @address.blank?
          flash[:notice] = 'Order Cannot be created due to Customer or Shipping Address Blank'
          format.html { redirect_to :action => "index" }
        else
          format.html # new.html.erb
          format.xml  { render :xml => @order }
        end
      end
    else
      respond_to do |format|
        flash[:notice] = 'Order Cannot be created due to Customer or Shipping Address Blank'
        format.html { redirect_to :action => "index" }
      end
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @customer = Customer.find(@order.customer_id)
    @address = ShippingAddress.find(@order.shipping_address_id)
  end

  # POST /orders
  # POST /orders.xml
  def create
    @order = Order.new(params[:order])
    if !params[:order][:reference].blank?
      status = params[:order][:status]
      @order.status = "Placed"
      if status =="Invoiced"
        @order.status = "Invoiced"
      end
    end

    respond_to do |format|
      if @order.save
        if params['xls']
          export_to_xls(@order)
          return
        end
        if params['slip'] 
          format.html { render 'slip', :layout => false }
          
        end
        if params['print'] 
          format.html { render 'print', :layout => false }
        else
          AdminNotifier.deliver_new_order_mail(@order,current_user)
          flash[:notice] = 'Order was successfully created'
          format.html { redirect_to :action => "index" }
          format.xml  { render :xml =>  @order, :status => :created, :location =>  @order }
        end
      else
        @customer = Customer.find(params[:order][:customer_id])
        @address = ShippingAddress.find(params[:order][:shipping_address_id])
        format.html { render :action => "new" }
        format.xml  { render :xml =>  @order.errors, :status => :unprocessable_entity }
      end
    end
  end
  def export_to_xls(order)
    ship_to = order.ship_to.split("\r\n")
    filename = "order.xlsx"
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Order") do |sheet|
        styles = sheet.styles
        po = "CEN"
        po = "CTI" if @order.company == "C" 
        po = po + '-' + @order.reference
        header = styles.add_style :bg_color => '00', :fg_color => 'FF', :b => true , :alignment => {:horizontal => :center}
        bold = styles.add_style :b => true
        border = styles.add_style :border => { :style => :thin, :color =>"00" }
        sheet.add_row [nil,nil,nil,"Order Confirmation",nil,nil,nil,nil,nil, nil],:style => [nil,nil,nil,bold,nil,nil,nil,nil,nil, nil]
        sheet.add_row
        if @order.company == "C"
          sheet.add_row
          sheet.add_row ["North America Office:",nil,nil,nil,nil,nil,nil,nil,"Date:",order.date_created], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["P.O. Box 84657",nil,nil,nil,nil,nil,nil,nil,"Order:", "CO-" + @order.order_confirmation.to_s + @order.customer.oc_code.to_s], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["2336 Bloor St. W.",nil,nil,nil,nil,nil,nil,nil,"Customer P.O.:", po], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Toronto, Ontario M6S 4Z7"]
          sheet.add_row ["Tel: (416) 767 9574"]
          sheet.add_row ["Fax: (416) 767 7505"]
          sheet.add_row ["info@ctiplastic.com"]
        else
          sheet.add_row ["83 Durie St.",nil,nil,nil,nil,nil,nil,nil,"Date:",order.date_created], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Toronto, Ontario M6S 3E7",nil,nil,nil,nil,nil,nil,nil,"Order:", "TO-"  + @order.customer.oc_code.to_s + @order.order_confirmation.to_s], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Tel: (416) 767 9574",nil,nil,nil,nil,nil,nil,nil,"Customer P.O.:", po], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Fax: (416) 767 7505"]
        end
        sheet.add_row [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Sold to:",order.customer.customer_name,nil,nil,nil,nil,nil,nil,"Ship to:", ship_to[0]], :style => [bold,nil,nil,nil,nil,nil,nil,nil,bold, nil]
        sheet.add_row [nil,order.customer.street_1,nil,nil,nil,nil,nil,nil,nil, ship_to[1]]
        sheet.add_row [nil,order.customer.street_2,nil,nil,nil,nil,nil,nil,nil, ship_to[2]]
        sheet.add_row [nil,order.customer.city,nil,nil,nil,nil,nil,nil,nil, ship_to[3]]
        sheet.add_row [nil,nil,nil,nil,nil,nil,nil,nil,nil, ship_to[4]]
        sheet.add_row ["Phone:",order.customer.phone,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Requested Delivery:",order.requested_delivery,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Terms:",order.customer.terms,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Delivery Terms:",order.customer.delivery_terms,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Reference:",order.reference,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Port:",order.customer.arrival_port,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Currency:",order.customer.currency,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Full/Mixed:",order.mixed_full,nil,nil,nil,nil,nil,nil,nil, nil], :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row
        sheet.add_row ["Item", "Colour", "Description", "Notes", "Drain","Skids", "Pack", "Total", "Price", "Total","Barcode No","Bar Line 1","Bar Line 2","Bar Line 3","Bar Line 4","Barcode Position"], :style => header
        total_amount = 0 
        total_price = 0
        @order.order_product_details.each do |product_form|
          code = "#{product_form.code}-#{product_form.colour}" if product_form.code.present?
          color = Color.name_for_abbr product_form.colour
          drain = "Yes" if product_form.drainage
          drain = "No" unless product_form.drainage
          total_amount = total_amount + product_form.total_amount
          total_price = total_price + product_form.total_price
          sheet.add_row [code, color, product_form.description, product_form.notes, drain ,product_form.skid, product_form.pack, product_form.total_amount, product_form.price, product_form.total_price, product_form.barcode_number, product_form.bar_line_one, product_form.bar_line_two, product_form.bar_line_three, product_form.bar_line_four,product_form.barcode_position],:style => [border,border,border,border,border,border,border,border,border, border,border,border,border,border,border,border, border]
        end
        sheet.add_row [nil, nil, nil, nil, nil ,nil, nil, total_amount, nil, total_price],:style => [nil,nil,nil,nil,nil,nil,nil,border,nil, border]
        sheet.column_widths 24, 12, 12, 12, 12, 12, 12 , 12 , 12 , 12, 12, 12, 12, 12, 12 , 20 , 12 , 20
        if @order.company == "C"
          sheet.add_image(:image_src => "cti_logo.jpg", :end_at => true) do |image|
            image.start_at 0, 0
            image.end_at 1, 3
          end
        else
          sheet.add_image(:image_src => "centrade_logo.jpg", :end_at => true) do |image|
            image.start_at 0, 0
            image.end_at 1, 2
          end
        end
        
      end
      p.serialize(filename)
    end
    if @order.company == "C"
      send_file(filename, options = {:filename => "CO-" + @order.customer.oc_code.to_s + @order.order_confirmation.to_s + ".xlsx"})
    else
      send_file(filename, options = {:filename => "TO-" + @order.customer.oc_code.to_s + @order.order_confirmation.to_s + ".xlsx"})
    end
    return
  end
  # PUT /orders/1
  # PUT /orders/1.xml
  def update

    @order = Order.find(params[:id])
    if !params[:order][:reference].blank?
      status = params[:order][:status]
      params[:order][:status] = "Placed"
      if status =="Invoiced"
        params[:order][:status] = "Invoiced"
      elsif status == "Discrepancy"
        params[:order][:status] = "Discrepancy"
      elsif status == "Approved"
        params[:order][:status] = "Approved"
      elsif status == "P.S."
        params[:order][:status] = "P.S."
      end
    else
      params[:order][:status] = "Pending"
    end

    respond_to do |format|
      if @order.update_attributes(params[:order])
        if params['xls']
          export_to_xls(@order)
          return
        end
        if params['slip'] 
          format.html { render 'slip', :layout => false }
          
        end
        if params['print']
          format.html { render 'print', :layout => false }
        else
          flash[:notice] = 'Order was successfully updated'
          format.html { redirect_to :action => "index" }
          format.xml  { head :ok }
        end
      else
        @customer = Customer.find(params[:order][:customer_id])
        @address = ShippingAddress.find(params[:order][:shipping_address_id])
        format.html { render :action => "edit" }
        format.xml  { render :xml =>  @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.xml
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to :action => "index" }
      format.xml  { head :ok }
    end
  end

  def customer_dropdown
    @customers = Customer.find(:all, :conditions => ["company = ? AND customer_status = ?",params[:company],"A"]) 
    render :layout => false
  end

  def shipping_address_dropdown
    @address = ShippingAddress.find_all_by_customer_id(params[:customer_id])
    render :layout => false
  end

  def product_details
    @specifications = Specification.find_by_item(params[:code])
    @attr_id_str = params[:attr_id_str].split("_attributes_")[1].gsub("_code","")
    render :layout => false
  end

  def edit_view_production_order
    @orders = Order.find_all_by_reference(params[:reference])  
  end

  def update_production_order
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes("eta_to_port" => params[:eta_to_port],"eta_to_customer" => params[:eta_to_customer],
          "confirmed_ship_date" => params[:confirmed_ship_date],"add_ship_charge" => params[:add_ship_charge])
        @order.customer.update_attributes("arrival_port" => params[:customer][:arrival_port])
        flash[:notice] = 'Production Order was successfully updated'
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        flash[:notice] = 'Production Order was Not successfully updated'
        format.html { render :action => "edit_view_production_order" }
        format.xml  { render :xml =>  @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_prod_order_barcode
    @order_prod_detail = OrderProductDetail.find(params[:id])
    @order_prod_detail.update_attributes("barcode_number" => params[:barcode_number],"bar_line_one" => params[:bar_line_one],
      "bar_line_four" => params[:bar_line_four],
      "bar_line_two" => params[:bar_line_two],"bar_line_three" => params[:bar_line_three],
      "barcode_position" => params[:barcode_position])
  end
  def symbol_to_port(symbol)
    case symbol 
      when "VAN_BC" 
        "Vancouver"
      when "CHA_IL" 
        "Chicago"
      when "CAL_AB"
        "Calgary"
      when "WIN_MB"
        "Winnipeg"
      when "TOR_ON"
        "Toronto"
      when "MON_QC"
        "Montreal"
      when "SEA_WA"
        "Seattle"
      when "POR_OR"
        "Portland"
      when "CLE_OH"
        "Cleveland"
      when "COL_OH"
        "Columbus"
      when "DET_MI"
        "Detroit"
      when "IND_IN"
        "Indianapolis"
      when "MIN_MN"
        "Minneapolis"
      when "NWY_NY"
        "New York"
      when "BAL_NC"
        "Baltimore"
      when "WIL_NC"
        "Wilmington"
      when "CHA_CS"
        "Charleston"
      when "SAN_CA"
        "San Francsico"
      when "LOS_CA"
        "Los Angeles"
      when "OAK_CA"
        "Oakland"
      when "DEN_CO"
        "Denver"
      when "ATL_GA"
        "Atlanta"
      when "CHA_NC"
        "Charlotte"
      when "SAL_UT"
        "Salt Lake City"
      when "DAL_TX"
        "Dallas"
      when "HOU_TX"
        "Houston"
      when "NOR_VA"
        "Norfolk"
      when "SAV_GA"
        "Savannah"
      when "MIA_FL"
        "Miami"
    end
  end
  def create_po(o)
    po = "CEN"
    po = "CTI" if o.first.company == "C" 
    po = po + '-' + o.first.reference
    po = po + '-MIX' if o.size > 1
    return po
  end
  def get_reference(so)
    so.customer.company + "O-" + so.customer.oc_code
  end
  def get_mixed_reference(o)
    if o.length > 1
      "mixed"
    else
      get_reference(o.first)
    end
  end
  def export_single_to_xml
    @order = Order.find_all_by_reference(params[:reference])
    ship_to_array = @order[0].ship_to.split("\r\n")
    
    
#    puts YAML::dump(@order)
    filename = "order.xlsx"
    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => "Order") do |sheet|
        styles = sheet.styles
        header = styles.add_style :b => true , :alignment => {:horizontal => :center, :vertical => :center}, :border => { :style => :thin, :color =>"00" }
        bold = styles.add_style :b => true
        title = styles.add_style :b => true, :sz => 18
        border = styles.add_style :border => { :style => :thin, :color =>"00" }
        sheet.add_row [nil,nil,"Purchase Order",nil,nil,"Date:",@order[0].date_created,nil,nil, nil],  :style => [nil,nil,title,nil,nil,bold,nil,nil,nil, nil]
        sheet.add_row [nil,nil,nil,nil,nil,"P.O.",create_po(@order),nil,nil, nil],                :style => [nil,nil,nil,nil,nil,bold,nil,nil,nil, nil]
        sheet.add_row [nil,nil,nil,nil,nil,"Sales:",nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,bold,nil,nil,nil, nil]
        sheet.add_row
        if @order[0].company == "C"
          sheet.add_row
          sheet.add_row ["North America Office:",nil,nil,nil,nil,nil,nil,nil], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["P.O. Box 84657",nil,nil,nil,nil,nil,nil,nil], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["2336 Bloor St. W.",nil,nil,nil,nil,nil,nil,nil], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Toronto, Ontario M6S 4Z7"]
          sheet.add_row ["Tel: (416) 767 9574"]
          sheet.add_row ["Fax: (416) 767 7505"]
          sheet.add_row ["info@ctiplastic.com"]
        else
          sheet.add_row ["83 Durie St.",nil,nil,nil,nil,nil,nil,nil], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Toronto, Ontario M6S 3E7",nil,nil,nil,nil,nil,nil,nil], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Tel: (416) 767 9574",nil,nil,nil,nil,nil,nil,nil], :style => [nil,nil,nil,nil,nil,nil,nil,nil,bold, nil]
          sheet.add_row ["Fax: (416) 767 7505"]
        end
        sheet.add_row
        sheet.add_row [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row
        sheet.add_row ["Purchase Fr:","China MBCC",nil,nil,"Ship to:",ship_to_array[0],nil,nil,nil, nil],              :style => [bold,nil,nil,nil,bold,nil,nil,nil,nil, nil]
        sheet.add_row [nil,"3F Hongde Mansion,20-1 Yunnan Road",nil,nil,nil,ship_to_array[1],nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row [nil,"Nanjing 210008, China",nil,nil,nil,ship_to_array[2],nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row [nil,nil,nil,nil,nil,ship_to_array[3],nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row [nil,nil,nil,nil,nil,ship_to_array[4],nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Ship Date",nil,nil,nil,nil,nil,nil,nil,nil, nil],              :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Shipping Port","Nanjing, China",nil,nil,nil,nil,nil, nil],              :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Destination",symbol_to_port(@order.first.customer.arrival_port),nil,nil,nil,nil,nil,nil,nil, nil],              :style => [bold,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil],              :style => [nil,nil,nil,nil,nil,nil,nil,nil,nil, nil]
        sheet.add_row ["Item", "Colour", "Description", "Skids", "Pack", "Total", "Bar Code", "Barcode Line #1", "Barcode Line #2", "Barcode Line #3", "Barcode Line #4", "Position"], :style => header
        @order.each { |item|
          nr_of_skids = 0 
          item.order_product_details.map {|i| nr_of_skids = nr_of_skids + i.skid}
          sheet.add_row ["Please label on all four sides - " + nr_of_skids.to_s + " Skids for " + item.customer.company + "O-" + item.customer.oc_code.to_s + item.order_confirmation], :style => bold
          item.order_product_details.each { |i|
            sheet.add_row [i.code, i.colour , i.description, i.skid, i.pack, i.total, i.barcode_number, i.bar_line_one, i.bar_line_two, i.bar_line_three, i.bar_line_four, i.barcode_position]
          }
          sheet.add_row
        }
        sheet.column_widths 24, 24, 24, 24, 24, 24, 24 , 24 , 24 , 24,24, 24, 24, 24, 24, 24, 24 , 24 , 24 , 24
        if @order[0].company == "C"
          sheet.add_image(:image_src => "cti_logo.jpg", :end_at => true) do |image|
            image.start_at 0, 0
            image.end_at 1, 3
          end
        else
          sheet.add_image(:image_src => "centrade_logo.jpg", :end_at => true) do |image|
            image.start_at 0, 0
            image.end_at 1, 3
          end
        end
      end
      p.serialize(filename)
    end
    send_file(filename, options = {:filename => create_po(@order) + ".xlsx"})
  end
  private
  def update_full_refs_and_ocs
    #Full OC
    if (!@order.customer.blank?  && !@order.customer.oc_code.blank?) 
      oc_code = (@order.customer.oc_code).upcase
    else
      oc_code = ""
    end
    full_oc = @order.company+"O-"+oc_code+" "+@order.order_confirmation
    #Full Reference
    if (@order.company == "C")
      full_ref = "CTI-"+@order.reference
    else
      full_ref = "CENT-"+@order.reference
    end
    @order.update_attributes(:order_confirmation => full_oc, :reference => full_ref)
  end

end
