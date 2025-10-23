require 'jwt'

class JwtService
  SECRET_KEY = Rails.application.credentials.jwt_secret || ENV['JWT_SECRET']
  ALGORITHM = 'HS256'
  EXPIRY = 24.hours.from_now.to_i

  class JwtError < StandardError; end

  # Generate JWT for a user
  def self.generate(user)
    payload = {
      user_id: user.id,
      exp: EXPIRY
    }
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  # Validate JWT and return payload
  def self.validate(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
    decoded.first.symbolize_keys
  rescue JWT::ExpiredSignature
    raise JwtError, "Token has expired"
  rescue JWT::DecodeError => e
    raise JwtError, "Invalid token: #{e.message}"
  end
end
