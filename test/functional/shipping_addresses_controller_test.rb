require 'test_helper'

class ShippingAddressesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:shipping_addresses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create shipping_address" do
    assert_difference('ShippingAddress.count') do
      post :create, :shipping_address => { }
    end

    assert_redirected_to shipping_address_path(assigns(:shipping_address))
  end

  test "should show shipping_address" do
    get :show, :id => shipping_addresses(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => shipping_addresses(:one).to_param
    assert_response :success
  end

  test "should update shipping_address" do
    put :update, :id => shipping_addresses(:one).to_param, :shipping_address => { }
    assert_redirected_to shipping_address_path(assigns(:shipping_address))
  end

  test "should destroy shipping_address" do
    assert_difference('ShippingAddress.count', -1) do
      delete :destroy, :id => shipping_addresses(:one).to_param
    end

    assert_redirected_to shipping_addresses_path
  end
end
