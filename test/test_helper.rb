ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "factory_bot_rails"
require "mocha/minitest"
require "shoulda"
require "helpers/foobar_mod"
require "helpers/mod_helpers"

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
  include FoobarMod::TestHelpers
  include ModHelpers

  def assert_date_equal(expected, date_str)
    assert_in_delta expected, ActiveSupport::TimeZone.new("UTC").parse(date_str), 1.second
  end
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end
