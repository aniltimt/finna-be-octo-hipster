require 'test_helper'

class ShippingSchedulePermissionTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test 'editable?' do
    permission = ShippingSchedulePermission.create!(:reference => ShippingSchedulePermission::EDITABLE)
    assert_equal permission.reference, ShippingSchedulePermission::EDITABLE
  end

  test 'get - for valid field' do
    permission = ShippingSchedulePermission.create!(:reference => ShippingSchedulePermission::EDITABLE)
    assert_equal permission.get(:reference), ShippingSchedulePermission::EDITABLE
  end

  test 'get - for invalid field' do
    permission = ShippingSchedulePermission.create!(:reference => ShippingSchedulePermission::EDITABLE)
    assert_nil permission.get(:some_field)
  end

  test 'visible_fields' do
    permission = ShippingSchedulePermission.create!(:reference => ShippingSchedulePermission::EDITABLE, :status => ShippingSchedulePermission::HIDDEN)
    assert_equal permission.visible_fields.include?('status'), false
  end
end
