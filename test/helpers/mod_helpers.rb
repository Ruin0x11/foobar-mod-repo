module ModHelpers
  def mod_file(name = "test-0.0.0.zip")
    Rails.root.join("test", "mods", name.to_s).open
  end
end
