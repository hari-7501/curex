class SmsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(mobile, message)
    SmsGatewayService.new(mobile, message).send_sms
  rescue SmsGatewayService::SmsError => e
    Rails.logger.error("Failed to send SMS to #{mobile}: #{e.message}")
  end
end
