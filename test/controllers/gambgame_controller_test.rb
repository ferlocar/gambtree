require 'test_helper'

class GambgameControllerTest < ActionController::TestCase
  test "should get play" do
    get :play
    assert_response :success
  end

end
