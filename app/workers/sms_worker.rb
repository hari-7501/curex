class SmsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(mobile, message)
    # SmsGatewayService.new(mobile, message).send_sms
  rescue SmsGatewayService::SmsError => e
    # optional: handle/log failed SMS here
  end
end
