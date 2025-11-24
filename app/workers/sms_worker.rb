class SmsWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform(mobile, message)
    TextbeeSmsGatewayService.new(mobile, message).send_sms
  end
end
