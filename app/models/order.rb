class Order < ActiveRecord::Base

  #attr_accessible :order_product_details_attributes
  
  CHECKED = "1"
  
  belongs_to :customer
  belongs_to :shipping_address

  has_many :order_product_details

  accepts_nested_attributes_for :order_product_details, :allow_destroy => true

   validates_presence_of :customer_po
  #  :requested_ship_date,:confirmed_ship_date,:eta_to_port,:eta_to_customer,:date_created,
  #  :order_confirmation,:status,:ship_to,:arrival_port,:terms,:delivery_terms,:mixed_full,
  #  :notes,:currency,:reference


  def update_from_schedule(field, value, user)
    if !field.nil? and [
        :reference,
        :date_created,
        :status,
        :customer_name,
        :order_confirmation,
        :requested_ship_date,
        :requested_delivery,
        :mixed_full,
        :arrival_port,
        :customer_city,
        :confirmed_ship_date,
        :eta_to_port,
        :eta_to_customer,
        :finished_date,
        :shipping_notes

    ].include?(field.to_sym) && user.role.shipping_schedule_permission.editable?(field)

      if field.to_s.starts_with?('customer_')
        if field.to_s == 'customer_name'
          self.customer.update_attribute(:customer_name, value)
        elsif field.to_s == 'customer_city'
          self.customer.update_attribute(:city, value)
        end
      end

      self.update_attribute(field, value)
      self.update_attributes(:updated_by => user.role.id)
    end
  end

  def self.get_schedule(filters = nil)
    if filters.nil?
      find(:all, :include => [:customer], :order => "created_at DESC")
    else
      find(:all, :include => [:customer], :order => "created_at DESC", :conditions => construct_conditions(filters))
    end
  end

  def self.construct_conditions(filters)
    cond_str = []
    cond_values = []

    [:customer_id, :status, :mixed_full].each do |attr|
      if filters[attr].present?
        cond_str << "#{attr} = ?"
        cond_values << filters[attr].to_s.downcase
      end
    end

    if filters[:confirmed_shipdate_after].present?
      cond_str << "confirmed_ship_date > ?"
      cond_values << Date.parse(filters[:confirmed_shipdate_after])
    elsif filters[:confirmed_shipdate_after_no_blanks] == CHECKED
      cond_str << "confirmed_ship_date IS NOT ?"
      cond_values << nil
    end
    
    if filters[:eta_to_port_after].present?
      cond_str << "eta_to_port > ?"
      cond_values << Date.parse(filters[:eta_to_port_after])
    elsif filters[:eta_to_port_after_no_blanks] == CHECKED
      cond_str << "eta_to_port IS NOT ?"
      cond_values << nil
    end

    if filters[:reference].present?
      cond_str << 'reference LIKE ?'
      cond_values << "%#{filters[:reference]}%"
    elsif filters[:reference_no_blanks] == CHECKED
      cond_str << "reference NOT LIKE ?"
      cond_values << "%-"
    end
    
    [cond_str.join(' AND ')] + cond_values
  end

  def customer_name
    self.customer.customer_name
  end

  def customer_city
    self.customer.city
  end

  def date_created
    # TODO only temporary - maybe created_at should be used instead custom made date_created column?
    self.created_at.to_date
  end

  def total_skids
    order_product_details.sum(:skid)
  end

  def total_amount
    order_product_details.sum(:total_amount)
  end

  def total_price
    order_product_details.collect(&:total_price).sum
  end

end
