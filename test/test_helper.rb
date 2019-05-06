ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "factory_bot_rails"
require "mocha/minitest"
require "shoulda"
require "helpers/foobar_mod"
require "helpers/mod_helpers"
require "helpers/asserts"

class ActiveSupport::TestCase
  # Add more helper methods to be used by all tests here...
  include FactoryBot::Syntax::Methods
  include FoobarMod::TestHelpers
  include ModHelpers
  include Asserts

  def setup
    tmpdir = File.realpath Dir.tmpdir
    @tempdir = File.join(tmpdir, "test_#{$$}")
    FileUtils.mkdir_p @tempdir

    Dir.chdir @tempdir

    @modhome  = File.join @tempdir, "mods"
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
