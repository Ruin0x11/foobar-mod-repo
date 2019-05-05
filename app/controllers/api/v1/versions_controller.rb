class Api::V1::VersionsController < Api::BaseController
  before_action :find_mod, only: [:index, :show]

  def index
    respond_to do |format|
      format.json { render json: @mod.versions }
    end
  end

  def show
    version = @mod.public_version_payload(params[:number])
    if version
      respond_to do |format|
        format.json { render json: version }
      end
    else
      render json: {error: t("not_found.version")}, status: :not_found
    end
  end
end
