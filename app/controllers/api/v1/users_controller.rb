class Api::V1::UsersController < ApplicationController
  include ParamsHelper
  include ServiceResponseHandler

  ALLOWED_FIELDS = [:mobile, :otp, :first_name, :last_name, :age].freeze

  def create
    user_params = permitted_params_for(:user, ALLOWED_FIELDS)
    result = UserService.new(user_params).call
    render_service_result(result)
  end
end
