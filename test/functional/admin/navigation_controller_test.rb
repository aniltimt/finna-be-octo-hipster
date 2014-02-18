require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/navigation_controller'

# Re-raise errors caught by the controller.
class Admin::NavigationController; def rescue_action(e) raise e end; end

class Admin::NavigationControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::NavigationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
