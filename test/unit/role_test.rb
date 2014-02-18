require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase
  fixtures :roles, :permissions

  test 'add_permission' do
    permission = permissions(:admin_permission)
    roles(:admin).add_permission permission
    assert_equal roles(:admin).permissions.include?(permissions(:admin_permission)), true
  end

  test 'remove_permission' do
    roles(:admin).add_permission permissions(:admin_permission)
    assert_equal roles(:admin).permissions.include?(permissions(:admin_permission)), true
    roles(:admin).remove_permission permissions(:admin_permission)
    assert_equal roles(:admin).permissions.include?(permissions(:admin_permission)), false
  end

end
