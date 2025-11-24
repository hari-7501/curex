class Api::V1::UsersController < ApplicationController
  include ParamsHelper

  skip_before_action :authenticate_request, only: [:create]

  ALLOWED_FIELDS = [:mobile, :otp, :first_name, :last_name, :age].freeze

  def create
    user_params = permitted_params_for(:user, ALLOWED_FIELDS)
    jwt = UserService.new(user_params).user_auth_handler
    if(jwt.present?)
      render json: { jwt: jwt }, status: :ok 
    else
      render json: { message: "OTP sent to #{user_params[:mobile]} successfully!!!" }, status: :ok
    end
  end
end
