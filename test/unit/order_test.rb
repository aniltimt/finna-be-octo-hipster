require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :users, :orders, :customers, :roles, :shipping_schedule_permissions

  test 'customer_name' do
    assert_equal orders(:one).customer_name, orders(:one).customer.customer_name
  end

  test 'customer_city' do
    assert_equal orders(:one).customer_name, orders(:one).customer.customer_name
  end


  test 'update_from_schedule' do
    old_reference = orders(:one).reference
    orders(:one).update_from_schedule(:reference, '2222', users(:admin))
    assert_not_equal orders(:one).reference, '2222'
    assert_equal orders(:one).reference, old_reference

    orders(:one).update_from_schedule(:status, 'new_status', users(:admin))
    assert_equal orders(:one).status, 'new_status'

    orders(:one).update_from_schedule(:customer_name, 'Jack', users(:admin))
    assert_not_equal orders(:one).customer_name, 'Jack'
  end

  test 'construct_conditions' do
    conditions = Order.construct_conditions(:reference => '1234', :customer_id => 10, :eta_to_port_after => '2013-05-05')
    assert_match /reference\sLIKE\s\?/, conditions.first
    assert_match /customer_id\s=\s\?/, conditions.first
    assert_match /eta_to_port\s\>\s\?/, conditions.first

    assert_equal 10, conditions[1].to_i
    assert_equal Date.parse('2013-05-05'), conditions[2]
    assert_equal '%1234%', conditions[3]
  end


  test 'get_schedule' do
    schedule = Order.get_schedule
    assert_equal Order.count, schedule.size

    schedule = Order.get_schedule(:reference => '11')
    assert_equal 1, schedule.size

    schedule = Order.get_schedule(:reference => '22')
    assert_equal 0, schedule.size
  end


end
