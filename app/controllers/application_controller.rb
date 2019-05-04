class ApplicationController < ActionController::Base
  include Clearance::Controller
  include HttpAcceptLanguage::AutoLocale

  def valid_page_param?(max_page)
    params[:page].respond_to?(:to_i) && params[:page].to_i.between?(Repo::DEFAULT_PAGE, max_page)
  end

  def set_page(max_page = Repo::MAX_PAGES)
    @page = Repo::DEFAULT_PAGE && return unless params.key?(:page)
    redirect_to_page_with_error && return unless valid_page_param?(max_page)

    @page = params[:page].to_i
  end
end
