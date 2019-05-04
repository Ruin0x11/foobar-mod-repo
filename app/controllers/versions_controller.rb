class VersionsController < ApplicationController
  before_action :set_version, only: [:show]

  # GET /versions
  def index
    @versions = Version.all
  end

  # GET /versions/1
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_version
    @version = Version.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def version_params
    params.require(:version).permit(:number, :mod_id)
  end
end
