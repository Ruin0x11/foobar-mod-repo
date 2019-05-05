class ModsController < ApplicationController
  before_action :find_mod, only: :show
  before_action :set_page, only: :index

  def index
    @mods = Mod.order(:identifier).includes(:latest_version).page(@page)
  end

  def show
    @latest_version ||= @mod.versions.most_recent
  end
end
