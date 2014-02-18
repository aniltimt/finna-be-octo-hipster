module Admin::ShippingScheduleHelper
  def schedule_json(orders)
    @orders.map do |order|
      {
          :id => order.id,
          :reference => order.reference,
          :date_created => order.created_at.try(:strftime,'%d-%m-%Y'),
          :status => order.status,
          :customer_name => order.customer_name,
          :customer_po => order.customer_po,
          :order_confirmation => order.order_confirmation,
          :mixed_full => order.mixed_full,
          :arrival_port => order.arrival_port,
          :customer_city => order.customer_city,
          :requested_delivery => order.requested_delivery.try(:strftime, '%d-%m-%Y'),
          :requested_ship_date => order.requested_ship_date.try(:strftime, '%d-%m-%Y'),
          :finished_date => order.finished_date.try(:strftime, '%d-%m-%Y'),
          :confirmed_ship_date => order.confirmed_ship_date.try(:strftime, '%d-%m-%Y'),
          :eta_to_port => order.eta_to_port.try(:strftime, '%d-%m-%Y'),
          :eta_to_customer => order.eta_to_customer.try(:strftime,'%d-%m-%Y'),
          :shipping_notes => order.shipping_notes,
          :edit_order_link => "http://" + request.host() + "/admin/orders/edit/" + order.id.to_s,
          :edit_production_order_link => "http://" + request.host() + "/edit_view_production_order?reference=" + order.reference.to_s,
          :colour => Role.find_by_id(order.updated_by).update_colour,
          :role => current_user.role.name
      }
    end.to_json
  end

  def handson_settings_json(user)
  
    col_settings = [
        {:name => :reference, :width => 70},
        {:name => :date_created, :width => 90},
        {:name => :status, :width => 80, :options => {:type => 'autocomplete', :source => ['', 'Placed', 'Pending', 'Invoiced', 'Discrepancy', 'Approved', 'P.S.'], :strict => true}},
        {:name => :customer_name, :header => "Customer", :width => 80},
        {:name => :customer_po, :header => "Customer PO", :width => 80},
        {:name => :order_confirmation, :width => 120},
        {:name => :mixed_full,  :header => "Mixed/Full", :width => 80, :options => {:type => 'autocomplete', :source => ['', 'Mixed', 'Full']}},
        {:name => :arrival_port, :width => 100},
        {:name => :customer_city, :width => 100},
        {:name => :requested_delivery, :header => "Request delivery", :width => 110, :options => {:type => 'date', :dateFormat => 'dd-mm-yy'}},
        {:name => :requested_ship_date, :header => "Request ship date", :width => 120, :options => {:type => 'date', :dateFormat => 'dd-mm-yy'}},
        {:name => :finished_date, :header => "Finished date", :width => 120, :options => {:type => 'date', :dateFormat => 'dd-mm-yy'}},
        {:name => :confirmed_ship_date, :width => 130, :options => {:type => 'date', :dateFormat => 'dd-mm-yy'}},
        {:name => :eta_to_port, :width => 100, :options => {:type => 'date', :dateFormat => 'dd-mm-yy'}},
        {:name => :eta_to_customer, :width => 100, :options => {:type => 'date', :dateFormat => 'dd-mm-yy'}},
        {:name => :shipping_notes, :width => 100},
        {:name => :edit_order_link, :width => 100},
        {:name => :edit_production_order_link, :width => 100}
    ]


    columns = {
        :colHeaders => [],
        :colWidths => [],
        :columns => []
    }

    col_settings.each do |set|
      perm = user.role.shipping_schedule_permission.get(set[:name])
      #No links for shipper.
      if perm != ShippingSchedulePermission::HIDDEN
        columns[:colHeaders] << (set[:header].present? ? set[:header] : set[:name].to_s.humanize)
        columns[:colWidths] << set[:width]
        column = {:data => set[:name].to_s}
        column.merge!(set[:options]) if set[:options].present?
        column.merge!(:readOnly => true) if perm == ShippingSchedulePermission::READ_ONLY
        columns[:columns] << column
      end
    end

    columns.to_json

  end
end
