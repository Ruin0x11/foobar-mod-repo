require "test_helper"

class VersionsTest < ApplicationSystemTestCase
  setup do
    @version = create(:version)
  end

  test "visiting the index" do
    visit versions_url
    assert_selector "h1", text: "Versions"
  end
end
