
# creating roles if missing any
Role.create(:codename => 'admin', :name => "Admin") unless Role.exists? :codename => 'admin'
Role.create(:codename => 'sales_staff', :name => "Sales Staff") unless Role.exists? :codename => 'sales_staff'
Role.create(:codename => 'shipper_carrier', :name => "Shipper/Carrier") unless Role.exists? :codename => 'shipper_carrier'
Role.create(:codename => 'production', :name => "Production") unless Role.exists? :codename => 'production'
Role.create(:codename => 'product_editor', :name => "Product Editor") unless Role.exists? :codename => 'product_editor'
Role.create(:codename => 'spreadsheet_admin', :name => "Spreadsheet Admin") unless Role.exists? :codename => 'spreadsheet_admin'

# setting up permissions
ShippingSchedulePermission.create(
    :role_id => Role.find_by_codename('admin').id,
    :reference => ShippingSchedulePermission::READ_ONLY,
    :date_created => ShippingSchedulePermission::READ_ONLY,
    :status => ShippingSchedulePermission::EDITABLE,
    :customer_name => ShippingSchedulePermission::READ_ONLY,
    :order_confirmation => ShippingSchedulePermission::EDITABLE,
    :requested_ship_date => ShippingSchedulePermission::EDITABLE,
    :requested_delivery => ShippingSchedulePermission::EDITABLE,
    :mixed_full => ShippingSchedulePermission::EDITABLE,
    :arrival_port => ShippingSchedulePermission::EDITABLE,
    :customer_city => ShippingSchedulePermission::EDITABLE,
    :confirmed_ship_date => ShippingSchedulePermission::EDITABLE,
    :eta_to_port => ShippingSchedulePermission::EDITABLE,
    :eta_to_customer => ShippingSchedulePermission::EDITABLE,
    :shipping_notes => ShippingSchedulePermission::EDITABLE
) if Role.exists? :codename => 'admin'

ShippingSchedulePermission.create(
    :role_id => Role.find_by_codename('sales_staff').id,
    :reference => ShippingSchedulePermission::READ_ONLY,
    :date_created => ShippingSchedulePermission::READ_ONLY,
    :status => ShippingSchedulePermission::EDITABLE,
    :customer_name => ShippingSchedulePermission::READ_ONLY,
    :order_confirmation => ShippingSchedulePermission::EDITABLE,
    :requested_ship_date => ShippingSchedulePermission::EDITABLE,
    :requested_delivery => ShippingSchedulePermission::EDITABLE,
    :mixed_full => ShippingSchedulePermission::READ_ONLY,
    :arrival_port => ShippingSchedulePermission::READ_ONLY,
    :customer_city => ShippingSchedulePermission::READ_ONLY,
    :confirmed_ship_date => ShippingSchedulePermission::READ_ONLY,
    :eta_to_port => ShippingSchedulePermission::READ_ONLY,
    :eta_to_customer => ShippingSchedulePermission::READ_ONLY,
    :shipping_notes => ShippingSchedulePermission::HIDDEN
) if Role.exists? :codename => 'sales_staff'

ShippingSchedulePermission.create(
    :role_id => Role.find_by_codename('shipper_carrier').id,
    :reference => ShippingSchedulePermission::READ_ONLY,
    :date_created => ShippingSchedulePermission::READ_ONLY,
    :status => ShippingSchedulePermission::HIDDEN,
    :customer_name => ShippingSchedulePermission::READ_ONLY,
    :order_confirmation => ShippingSchedulePermission::READ_ONLY,
    :requested_ship_date => ShippingSchedulePermission::HIDDEN,
    :requested_delivery => ShippingSchedulePermission::READ_ONLY,
    :mixed_full => ShippingSchedulePermission::READ_ONLY,
    :arrival_port => ShippingSchedulePermission::READ_ONLY,
    :customer_city => ShippingSchedulePermission::READ_ONLY,
    :confirmed_ship_date => ShippingSchedulePermission::READ_ONLY,
    :eta_to_port => ShippingSchedulePermission::EDITABLE,
    :eta_to_customer => ShippingSchedulePermission::EDITABLE,
    :shipping_notes => ShippingSchedulePermission::EDITABLE
) if Role.exists? :codename => 'shipper_carrier'

ShippingSchedulePermission.create(
    :role_id => Role.find_by_codename('production').id,
    :reference => ShippingSchedulePermission::READ_ONLY,
    :date_created => ShippingSchedulePermission::READ_ONLY,
    :status => ShippingSchedulePermission::HIDDEN,
    :customer_name => ShippingSchedulePermission::READ_ONLY,
    :order_confirmation => ShippingSchedulePermission::READ_ONLY,
    :requested_ship_date => ShippingSchedulePermission::HIDDEN,
    :requested_delivery => ShippingSchedulePermission::READ_ONLY,
    :mixed_full => ShippingSchedulePermission::READ_ONLY,
    :arrival_port => ShippingSchedulePermission::READ_ONLY,
    :customer_city => ShippingSchedulePermission::READ_ONLY,
    :confirmed_ship_date => ShippingSchedulePermission::EDITABLE,
    :eta_to_port => ShippingSchedulePermission::EDITABLE,
    :eta_to_customer => ShippingSchedulePermission::EDITABLE,
    :shipping_notes => ShippingSchedulePermission::EDITABLE
) if Role.exists? :codename => 'production'

ShippingSchedulePermission.create(
    :role_id => Role.find_by_codename('product_editor').id,
    :reference => ShippingSchedulePermission::READ_ONLY,
    :date_created => ShippingSchedulePermission::READ_ONLY,
    :status => ShippingSchedulePermission::EDITABLE,
    :customer_name => ShippingSchedulePermission::READ_ONLY,
    :order_confirmation => ShippingSchedulePermission::EDITABLE,
    :requested_ship_date => ShippingSchedulePermission::EDITABLE,
    :requested_delivery => ShippingSchedulePermission::EDITABLE,
    :mixed_full => ShippingSchedulePermission::EDITABLE,
    :arrival_port => ShippingSchedulePermission::EDITABLE,
    :customer_city => ShippingSchedulePermission::EDITABLE,
    :confirmed_ship_date => ShippingSchedulePermission::EDITABLE,
    :eta_to_port => ShippingSchedulePermission::EDITABLE,
    :eta_to_customer => ShippingSchedulePermission::EDITABLE,
    :shipping_notes => ShippingSchedulePermission::EDITABLE
) if Role.exists? :codename => 'product_editor'

ShippingSchedulePermission.create(
    :role_id => Role.find_by_codename('spreadsheet_admin').id,
    :reference => ShippingSchedulePermission::READ_ONLY,
    :date_created => ShippingSchedulePermission::READ_ONLY,
    :status => ShippingSchedulePermission::EDITABLE,
    :customer_name => ShippingSchedulePermission::READ_ONLY,
    :order_confirmation => ShippingSchedulePermission::EDITABLE,
    :requested_ship_date => ShippingSchedulePermission::EDITABLE,
    :requested_delivery => ShippingSchedulePermission::EDITABLE,
    :mixed_full => ShippingSchedulePermission::EDITABLE,
    :arrival_port => ShippingSchedulePermission::EDITABLE,
    :customer_city => ShippingSchedulePermission::EDITABLE,
    :confirmed_ship_date => ShippingSchedulePermission::EDITABLE,
    :eta_to_port => ShippingSchedulePermission::EDITABLE,
    :eta_to_customer => ShippingSchedulePermission::EDITABLE,
    :shipping_notes => ShippingSchedulePermission::EDITABLE
) if Role.exists? :codename => 'spreadsheet_admin'