class UserService

  INDIAN_MOBILE_REGEX = /\A[6-9]\d{9}\z/.freeze

  def initialize(params)
    @params = params
  end

  def send_otp
    validations
    @user = User.find_by(mobile: @params[:mobile])
    if @user.nil?
      raise ValidationError.new("first_name is required") if @params[:first_name].blank?

      @user = User.create!(
        mobile: @params[:mobile],
        first_name: @params[:first_name],
        last_name: @params[:last_name],
        age: @params[:age]
      )
    end
    if(REDIS.get("otp:#{@user.mobile}").nil?)
      OtpService.new(@user.mobile).send_otp
    end
  end

  def verify_otp
    validations
    @user = User.find_by(mobile: @params[:mobile])
    raise ValidationError.new("invalid user") if @user.nil?

    verified = OtpService.new(@user.mobile).verify_otp(@params[:otp])
    raise ValidationError.new("Invalid OTP") unless verified

    create_default_wallets
    JwtService.generate(@user)
  end

  private

  def validations
    raise ValidationError.new("Mobile is required") unless @params[:mobile].present?
    raise ValidationError.new("Invalid mobile number") unless INDIAN_MOBILE_REGEX.match?(@params[:mobile])
  end

  def create_default_wallets
    return if @user.wallets.exists?

    ActiveRecord::Base.transaction do
      %w[usd inr eur gbp jpy].each do |currency|
        @user.wallets.create!(currency: currency, balance: 0)
      end
    end
  end
end
