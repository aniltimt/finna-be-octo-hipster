class Admin::ShippingScheduleController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions

  # permissions
  protected
  def check_permissions
    access_control({
                       :edit => ["update"],
                       :list => ["index"]
                   })
  end

  public
  # end of permissions

  def index
    @orders = Order.get_schedule(params[:filters])
    respond_to do |format|
      format.html do
        @customers = [''] + Customer.all.map { |c| [c.customer_name, c.id] }
      end
      format.json
      format.csv do
        csv_string = FasterCSV.generate do |csv|
          visible_fields = current_user.role.shipping_schedule_permission.visible_fields
          possible_fields = [:reference, :date_created, :status, :customer_name, :customer_po, :order_confirmation, 
                             :mixed_full, :arrival_port, :customer_city, :requested_delivery, :requested_ship_date, 
                             :finished_date, :confirmed_ship_date, :eta_to_port, :eta_to_customer]
          result_fields = []
          headers = []
          possible_fields.each do |pf|
            if visible_fields.include? pf.to_s
              result_fields << pf

              if pf == :mixed_full
                headers << 'Mixed/Full'
              elsif pf == :requested_ship_date
                headers << 'Request ship date'
              elsif pf == :requested_delivery
                headers << 'Request delivery'
              elsif pf == :finished_date
                headers << 'Finished date'
              elsif pf == :customer_po
                headers << 'Customer PO'
              else
                headers << pf.to_s.humanize
              end
            end
          end

          csv << headers
          
          @orders.each do |order|
            row = []
            result_fields.each do |field|
              row << order.send(field)
            end
            csv << row
          end
        end
        send_data(csv_string,
                  :type => 'text/csv; charset=utf-8; header=present',
                  :filename => "CTI-Shipping-Schedule-#{Time.now.strftime('%Y-%m-%d')}.csv")
      end
    end
  end

  def update
    order = Order.find(params[:order_id])
    order.update_from_schedule(params[:field], params[:value], current_user)
    respond_to do |format|
      format.json { render :json => {:status => :ok} }
    end
  end
  
end