ActionController::Routing::Routes.draw do |map|

  #map.resources :shipping_addresses
  #map.resources :customers
  #map.resources :orders
  map.connect '/new_order', :controller => "admin/orders", :action => 'new'
  map.connect '/customer_dropdown', :controller => "admin/orders", :action => 'customer_dropdown'
  map.connect '/shipping_address_dropdown', :controller => "admin/orders", :action => 'shipping_address_dropdown'
  map.connect '/shipping_province_dropdown', :controller => "admin/shipping_addresses", :action => 'shipping_province_dropdown'
  map.connect '/province_dropdown', :controller => "admin/customers", :action => 'province_dropdown'
  map.shipping_schedule_update '/admin/shipping_schedule/update', :controller => 'admin/shipping_schedule', :action => 'update'
  map.shipping_schedule '/admin/shipping_schedule.:format', :controller => 'admin/shipping_schedule', :action => 'index'
  map.connect '/product_code', :controller => "admin/orders", :action =>'product_details'
  map.connect '/edit_view_production_order', :controller => "admin/orders", :action =>'edit_view_production_order'
  map.connect '/update_production_order', :controller => "admin/orders", :action =>'update_production_order'
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"
  map.connect '', :controller => 'website', :action => 'show_page', :url => "home"
  map.connect 'admin/', :controller => "admin/welcome"
  map.page_not_found 'page_not_found', :controller => 'website', :action => 'page_not_found'

  map.resources :spreadsheets,
                :member => {
                    :enable => :get,
                    :disable => :get,
                    :unhighlight => :get,
                    :add_notes => :put
                },
                :collection => {:log => :get} do |spreadsheet|

    spreadsheet.resources :order_confirmations
  end

  map.logout 'logout', :controller => "admin/account", :action => :logout


  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
  map.connect '*url', :controller => 'website', :action => 'show_page'
end
