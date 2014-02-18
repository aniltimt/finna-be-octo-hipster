class Password < ActiveRecord::Base

  validates_presence_of :title, :value

  has_and_belongs_to_many :categories,
    :class_name => "Category",
    :join_table => "categories_passwords",
    :association_foreign_key => "category_id",
    :foreign_key => "password_id"

end