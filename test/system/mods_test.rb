require "test_helper"

class ModsTest < ApplicationSystemTestCase
  setup do
    @mod = create(:mod)
  end

  test "visiting the index" do
    visit mods_url
    assert_selector "h1", text: "Mods"
  end
end
