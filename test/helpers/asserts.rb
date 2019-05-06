module Asserts
  def assert_date_equal(expected, date_str)
    assert_in_delta expected, ActiveSupport::TimeZone.new("UTC").parse(date_str), 1.second
  end

  def assert_path_exists(path, msg = nil)
    msg = message(msg) { "Expected path '#{path}' to exist" }
    assert File.exist?(path), msg
  end

  def assert_directory_exists(path, msg = nil)
    msg = message(msg) { "Expected path '#{path}' to be a directory" }
    assert_path_exists path
    assert File.directory?(path), msg
  end
end
