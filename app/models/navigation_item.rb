class NavigationItem < ActiveRecord::Base
  
  acts_as_tree :order => "position", :counter_cache => true
  belongs_to :media_object
  
  def self.file_path 
    return "#{RAILS_ROOT}/public/assets/navigation_holder/"
  end
  
end
