require 'test_helper'

class VersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @version = create(:version)
  end

  test "should get index" do
    get mod_versions_url(mod_id: @version.mod.identifier)
    assert_response :success
  end

  test "should show version" do
    get mod_version_url(mod_id: @version.mod.identifier, id: @version)
    assert_response :success
  end
end
