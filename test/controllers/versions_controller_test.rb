require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @version = create(:version)
  end

  test "should get index" do
    get versions_url
    assert_response :success
  end

  test "should show version" do
    get version_url(@version)
    assert_response :success
  end
end
