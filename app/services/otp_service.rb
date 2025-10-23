class OtpService
  OTP_LENGTH = 6
  OTP_TTL = 3.minutes

  def initialize(mobile)
    @mobile = mobile.to_s.strip
  end

  # Generate and send OTP to the mobile number
  def send_otp
    otp = generate_otp
    RedisService.set(otp_key, otp, ttl: OTP_TTL)
    SmsWorker.perform_async(@mobile, "Your OTP is #{otp}. It is valid for #{OTP_TTL / 60} minutes.")  
    otp
  end

  # Verify the OTP entered by the user
  def verify_otp(input_otp)
    stored_otp = RedisService.get(otp_key)
    return false unless stored_otp

    if stored_otp == input_otp.to_s
      RedisService.delete(otp_key)
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
