class OtpService
  OTP_LENGTH = 6
  OTP_TTL = 3.minutes

  def initialize(mobile)
    @mobile = mobile.to_s.strip
  end

  # Generate and send OTP to the mobile number
  def send_otp
    otp = generate_otp
    REDIS.setex(otp_key, OTP_TTL, otp)
    SmsWorker.perform_async(@mobile, "Your OTP is #{otp}. It is valid for #{OTP_TTL / 60} minutes.")  
    otp
  end

  # Verify the OTP entered by the user
  def verify_otp(input_otp)
    stored_otp = REDIS.get(otp_key)
    return false unless stored_otp

    if stored_otp == input_otp.to_s
      REDIS.del(otp_key)
      true
    else
      false
    end
  end

  private

  def generate_otp
    "%06d" % rand(10**OTP_LENGTH)
  end

  def otp_key
    "otp:#{@mobile}"
  end
end
