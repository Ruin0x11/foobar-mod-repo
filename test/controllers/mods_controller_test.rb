require "test_helper"

class ModsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mod = create(:mod)
  end

  test "should get index" do
    get mods_url
    assert_response :success
  end

  test "should show mod" do
    get mod_url(@mod)
    assert_response :success
  end
end
