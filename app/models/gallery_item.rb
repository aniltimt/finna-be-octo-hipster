class GalleryItem < ActiveRecord::Base
  
  belongs_to :style, :class_name => "::Style"
  
  def before_create
    self.position = self.class.maximum(:position).to_i + 1
  end

  has_attached_file :image, :styles => {:thumb => "100x1500>", :medium => "600x1500>", :large => "1000x1500>" },
    :url => "/assets/product_catalogue/gallery_items/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/product_catalogue/gallery_items/:id/:style/:basename.:extension"

  validates_attachment_content_type :image,
    :content_type => ["image/pjpeg", "image/jpeg", "image/x-png", "image/png", "image/gif"]

  validates_attachment_size :image, :less_than => 10.megabytes
  
end
