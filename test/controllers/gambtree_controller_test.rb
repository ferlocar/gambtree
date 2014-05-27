require 'test_helper'

class GambtreeControllerTest < ActionController::TestCase
  test "should get pending_requests" do
    get :pending_requests
    assert_response :success
  end

end
