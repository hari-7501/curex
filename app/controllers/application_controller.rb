class ApplicationController < ActionController::API
  include GlobalErrorHandler
  include Authenticatable
  include PaginationParams
end
