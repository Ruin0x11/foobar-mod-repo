source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "bootsnap", ">= 1.1.0", require: false
gem "clearance", "~> 1.16"
gem "globalize", "~> 5.2.0"
gem "high_voltage", "~> 3.1"
gem "digest-sha3", "~> 1.1"
gem "http_accept_language"
gem "kaminari", "~> 1.1"
gem "mini_magick", "~> 4.8"
gem "pg"
gem "puma", "~> 3.11"
gem "rails", "~> 5.2.2", ">= 5.2.2.1"
gem "slim-rails", "~> 3.2"
gem "sqlite3", "~> 1.3", "< 1.4"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "validates_formatting_of", "~> 0.9"
gem "rubyzip", "~> 1.2"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails", "~> 5.0", require: false
  gem "irb", require: false
  gem "pry-rails", "~> 0.3"
  gem "rubocop", require: false
end

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "rails-erd", "~> 1.5"
end

group :test do
  gem "minitest-rails", "~> 3.0"
  gem "capybara", ">= 2.15"
  gem "webdrivers", "~> 3.0"
  gem 'mocha', require: false
  gem "shoulda"
end
