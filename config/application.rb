require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Repo
  class Application < Rails::Application
    config.load_defaults 5.2

    config.i18n.available_locales = %w(en ja)
  end

  DEFAULT_PAGE = 1
  MAX_PAGES = 1000
end
