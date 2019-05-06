require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Repo
  class Application < Rails::Application
    config.load_defaults 5.2

    config.time_zone = "UTC"
    config.encoding  = "utf-8"
    config.serve_static_files = Rails.env.development?

    config.i18n.available_locales = [:en, :ja]
    config.i18n.fallbacks = [:en]

    config.foobar_repo = Application.config_for :foobar_repo
  end

  def self.config
    Rails.application.config.foobar_repo
  end

  DEFAULT_PAGE = 1
  MAX_PAGES = 1000
  HOST = config['host']
  PROTOCOL = config['protocol']

  ##
  # The maximum number of displayable mods in Elona Foobar's mod list
  # screen. (It's the same as the maximum number of selection keys.)

  COUNT_PER_FOOBAR_PAGE = 18
end
