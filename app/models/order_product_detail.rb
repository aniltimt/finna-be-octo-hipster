class OrderProductDetail < ActiveRecord::Base
  belongs_to :order
  has_many :product_barcodes

  accepts_nested_attributes_for :product_barcodes, :allow_destroy => true

  def total_price
    price.present? ? total_amount * price : 0.0
  end

  def total_amount
    skid.present? && pack.present? ? skid * pack : 0
  end
end
