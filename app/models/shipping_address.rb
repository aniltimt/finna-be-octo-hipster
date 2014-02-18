class ShippingAddress < ActiveRecord::Base
  belongs_to :customer
  has_many :orders
  validates_presence_of :title,:receiver_name,:email,:phone,:street_1, :message => 'required'
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
