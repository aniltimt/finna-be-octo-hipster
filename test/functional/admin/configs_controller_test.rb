require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/configs_controller'

# Re-raise errors caught by the controller.
class Admin::ConfigsController; def rescue_action(e) raise e end; end

class Admin::ConfigsControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::ConfigsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
