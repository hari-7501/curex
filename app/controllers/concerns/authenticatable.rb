module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last
    return render_unauthorized("Missing token") unless token

    begin
      payload = JwtService.validate(token)
      @current_user = User.find(payload[:user_id])
    rescue JwtService::JwtError => e
      raise AuthError.new(e.message)
    end
  end

  def current_user
    @current_user
  end
end
