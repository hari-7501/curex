class UserService
  include ParamsValidator

  def initialize(params)
    @params = params
  end

  # if user does not exist, create user and send OTP
  # if user exists, send OTP or verify OTP and return JWT
  def call
    return Result.new(false, nil, "Mobile is required") if required_fields_missing(@params, [:mobile]).any?

    user = User.find_by(mobile: @params[:mobile])

    if user.nil?
      missing = required_fields_missing(@params, [:first_name, :last_name, :age])
      return Result.new(false, nil, "Missing fields: #{missing.join(', ')}") if missing.any?

      user = User.create!(
        mobile: @params[:mobile],
        first_name: @params[:first_name],
        last_name: @params[:last_name],
        age: @params[:age]
      )

      OtpService.new(user.mobile).send_otp
      return Result.new(true, { message: "OTP sent to mobile" }, nil)
    else
      if @params[:otp].present?
        verified = OtpService.new(user.mobile).verify_otp(@params[:otp])
        return Result.new(false, nil, "Invalid OTP") unless verified

        create_default_wallets_for(user)
        jwt = JwtService.generate(user)
        return Result.new(true, { jwt: jwt }, nil)
      else
        if(RedisService.get("otp:#{user.mobile}").nil?)
          OtpService.new(user.mobile).send_otp
        end
        return Result.new(true, { message: "OTP sent to mobile" }, nil)
      end
    end
  end

  private

  def create_default_wallets_for(user)
    return if user.wallets.exists?

    Wallet.transaction do
      %w[usd inr eur gbp jpy].each do |currency|
        user.wallets.create!(currency: currency, balance: 0)
      end
    end
  end
end
