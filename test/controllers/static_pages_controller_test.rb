require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get try_ruby" do
    get static_pages_try_ruby_url
    assert_response :success
  end

end
