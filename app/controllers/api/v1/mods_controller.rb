class Api::V1::ModsController < Api::BaseController
  before_action :find_mod, only: [:show]

  def index
    page = params[:page] || Repo::DEFAULT_PAGE
    mods = Mod.page(page)
    respond_to do |format|
      format.json { render json: mods }
    end
  end

  def show
    respond_to do |format|
      format.json { render json: @mod }
    end
  end
end
