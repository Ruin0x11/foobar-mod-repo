class ModsController < ApplicationController
  before_action :set_mod, only: [:show]
  before_action :set_page, only: :index

  # GET /mods
  def index
    @mods = Mod.order(:identifier).includes(:latest_version).page(@page)
  end

  # GET /mods/1
  def show
    @latest_version ||= @mod.versions.most_recent
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_mod
    @mod = Mod.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def mod_params
    params.require(:mod).permit(:id)
  end
end
