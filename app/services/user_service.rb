class UserService
  include ParamsValidator

  INDIAN_MOBILE_REGEX = /\A[6-9]\d{9}\z/.freeze

  def initialize(params)
    @params = params
  end

  # if user does not exist, create user and send OTP
  # if user exists, send OTP or verify OTP and return JWT
  def user_auth_handler
    raise ValidationError.new("Mobile is required") if required_fields_missing(@params, [:mobile]).any?
    raise ValidationError.new("Invalid mobile number") unless INDIAN_MOBILE_REGEX.match?(@params[:mobile])

    user = User.find_by(mobile: @params[:mobile])

    if user.nil?
      missing = required_fields_missing(@params, [:first_name, :last_name, :age])
      raise ValidationError.new("Missing fields: #{missing.join(', ')}") if missing.any?

      user = User.create!(
        mobile: @params[:mobile],
        first_name: @params[:first_name],
        last_name: @params[:last_name],
        age: @params[:age]
      )

      OtpService.new(user.mobile).send_otp
      nil
    else
      if @params[:otp].present?
        verified = OtpService.new(user.mobile).verify_otp(@params[:otp])
        raise ValidationError.new("Invalid OTP") unless verified

        create_default_wallets_for(user)
        JwtService.generate(user)
      else
        if(REDIS.get("otp:#{user.mobile}").nil?)
          OtpService.new(user.mobile).send_otp
        end
        nil
      end
    end
  end

  private

  def create_default_wallets_for(user)
    return if user.wallets.exists?

    ActiveRecord::Base.transaction do
      %w[usd inr eur gbp jpy].each do |currency|
        user.wallets.create!(currency: currency, balance: 0)
      end
    end
  end
end
