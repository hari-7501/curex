class Api::V1::UsersController < ApplicationController

  skip_before_action :authenticate_request

  def send_otp
    UserService.new(send_otp_params).send_otp
    render json: { message: "OTP sent to #{send_otp_params[:mobile]} successfully!!!" }
  end

  def verify_otp
    jwt = UserService.new(verify_otp_params).verify_otp
    render json: { jwt: jwt }
  end

  private

  def send_otp_params
    params.permit(:mobile, :first_name, :last_name, :age)
  end

  def verify_otp_params
    params.permit(:mobile, :otp)
  end
end
