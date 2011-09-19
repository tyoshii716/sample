require 'test_helper'

class MainControllerTest < ActionController::TestCase
  test "should get hoge" do
    get :hoge
    assert_response :success
  end

end
