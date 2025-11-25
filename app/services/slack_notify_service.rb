require 'net/http'
require 'json'

class SlackNotifyService
  WEBHOOK_URL = ENV.fetch('SLACK_WEBHOOK_URL')

  def self.notify(message, level: "error")
    return unless WEBHOOK_URL.present?

    payload = { text: "[#{level.upcase}] #{message}" }.to_json
    uri = URI(WEBHOOK_URL)

    response = Net::HTTP.post(uri, payload, "Content-Type" => "application/json")
    Rails.logger.info("Slack notification sent: #{response.code}") if response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    Rails.logger.error("Slack notification failed: #{e.message}")
  end
end
