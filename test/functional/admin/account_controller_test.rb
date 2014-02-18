require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/account_controller'

# Re-raise errors caught by the controller.
class Admin::AccountController; def rescue_action(e) raise e end; end

class Admin::AccountControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
