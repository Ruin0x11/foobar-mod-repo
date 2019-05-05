class ApplicationController < ActionController::Base
  include Clearance::Controller
  include HttpAcceptLanguage::AutoLocale

  rescue_from ActionController::UnknownFormat do
    head :not_acceptable
  end

  def find_mod
    @mod = Mod.find_by_identifier(params[:mod_id] || params[:id])
    return if @mod
    respond_to do |format|
      format.any do
        render plain: t("not_found.mod"), status: :not_found
      end
      format.json do
        render json: {error: t("not_found.mod")}, status: :not_found
      end
      format.html do
        render file: "public/404", status: :not_found, layout: false, formats: [:html]
      end
    end
  end

  def valid_page_param?(max_page)
    params[:page].respond_to?(:to_i) && params[:page].to_i.between?(Repo::DEFAULT_PAGE, max_page)
  end

  def set_page(max_page = Repo::MAX_PAGES)
    @page = Repo::DEFAULT_PAGE && return unless params.key?(:page)
    redirect_to_page_with_error && return unless valid_page_param?(max_page)

    @page = params[:page].to_i
  end
end
