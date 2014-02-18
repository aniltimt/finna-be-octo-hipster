class Customer < ActiveRecord::Base
  has_many :shipping_addresses
  has_many :orders
  validates_presence_of :user_name,:customer_name,:company,:password,:region,:currency,:contact_name,:email,:phone, :message => 'required'
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :oc_code

  def self.find_and_authenticate_with user_name, password
    if (customer = find_by_user_name(user_name)).present?
      customer if customer.password == password
    end
  end
end
