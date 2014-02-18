class Category < ActiveRecord::Base

  acts_as_tree :order => "position", :counter_cache => true
  has_many  :styles, :dependent => :destroy, :class_name => "::Style"

  def before_create
    self.position = self.class.maximum(:position).to_i + 1
  end

  has_and_belongs_to_many :passwords,
    :class_name => "Password",
    :join_table => "categories_passwords",
    :association_foreign_key => "password_id",
    :foreign_key => "category_id"
  
  has_attached_file :image, :styles => { :thumb => "150x1500>", :medium => "600x1500>", :large => "1000x1500px" },
    :url => "/assets/product_catalogue/categories/:id/:style/:basename.:extension",
    :path => ":rails_root/public/assets/product_catalogue/categories/:id/:style/:basename.:extension"

  validates_attachment_content_type :image,
    :content_type => ["image/pjpeg", "image/jpeg", "image/x-png", "image/png", "image/gif"]

  validates_attachment_size :image, :less_than => 10.megabytes

end
