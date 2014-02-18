class Style < ActiveRecord::Base

  belongs_to :category
  has_many :specifications
  has_many :items, :class_name => 'GalleryItem', :foreign_key => "style_id", :dependent => :destroy

  def before_create
    self.position = self.class.maximum(:position).to_i + 1
  end

  has_attached_file :image, :styles => {:thumb => "200x1500>", :medium => "600x1500>", :large => "1000x1500>"},
    :url => "/assets/product_catalogue/styles/image/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/product_catalogue/styles/image/:id/:style/:basename.:extension"
  validates_attachment_content_type :image,
    :content_type => ["image/pjpeg", "image/jpeg", "image/x-png", "image/png", "image/gif"],
    :unless => Proc.new { |imports| imports.image_file_name.blank? }
  validates_attachment_size :image, :less_than => 10.megabytes,
    :unless => Proc.new { |imports| imports.image_file_name.blank? }

  has_attached_file :image2, :styles => {:thumb => "200x1500>", :medium => "600x1500>", :large => "1000x1500>"},
    :url => "/assets/product_catalogue/styles/image2/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/product_catalogue/styles/image2/:id/:style/:basename.:extension"
  validates_attachment_content_type :image2,
    :content_type => ["image/pjpeg", "image/jpeg", "image/x-png", "image/png", "image/gif"],
    :unless => Proc.new { |imports| imports.image2_file_name.blank? }
  validates_attachment_size :image2, :less_than => 10.megabytes,
    :unless => Proc.new { |imports| imports.image2_file_name.blank? }

  has_attached_file :image3, :styles => {:thumb => "200x1500>", :medium => "600x1500>", :large => "1000x1500>"},
    :url => "/assets/product_catalogue/styles/image3/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/product_catalogue/styles/image3/:id/:style/:basename.:extension"
  validates_attachment_content_type :image3,
    :content_type => ["image/pjpeg", "image/jpeg", "image/x-png", "image/png", "image/gif"],
    :unless => Proc.new { |imports| imports.image3_file_name.blank? }
  validates_attachment_size :image3, :less_than => 10.megabytes,
    :unless => Proc.new { |imports| imports.image3_file_name.blank? }

  has_attached_file :palette,
    :url => "/assets/product_catalogue/styles/palette/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/product_catalogue/styles/palette/:id/:style/:basename.:extension",
    :default_url => "/assets/product_catalogue/styles/palette/default/default_colour_story.jpg"
  validates_attachment_content_type :palette,
    :content_type => ["image/pjpeg", "image/jpeg", "image/x-png", "image/png", "image/gif"],
    :unless => Proc.new { |imports| imports.palette_file_name.blank? }
  validates_attachment_size :palette, :less_than => 10.megabytes,
    :unless => Proc.new { |imports| imports.palette_file_name.blank? }

  def all_images
    [image, image2, image3]
  end

  def images
    all_images.delete_if { |img| !img.exists? }
  end

end
