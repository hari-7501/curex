module PaginationParams extend ActiveSupport::Concern

  PAGINATION_DEFAULT_PER_PAGE = 10
  PAGINATION_MAX_PER_PAGE = 100

  included do
    before_action :set_pagination_params
  end

  def paginated_params
    params.permit(:page, :per_page)
  end

  private

  def set_pagination_params
    @page     = params[:page].to_i
    @per_page = params[:per_page].to_i

    @page     = 1 if @page < 1
    @per_page = PAGINATION_DEFAULT_PER_PAGE if @per_page < 1
    @per_page = PAGINATION_MAX_PER_PAGE if @per_page > PAGINATION_MAX_PER_PAGE
  end

  def page
    @page
  end

  def per_page
    @per_page
  end
end
