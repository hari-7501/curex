require 'net/http'
require 'uri'
require 'json'

class TextbeeSmsGatewayService
  TEXTBEE_URL = "https://api.textbee.dev/api/v1/gateway/devices/68f153c26a418a16ec879298/send-sms".freeze
  API_KEY = ENV.fetch("TEXT_BEE_API_KEY", "").freeze
  COUNTRY_CODE = "+91".freeze

  def initialize(mobile, message)
    @mobile = mobile.to_s.strip
    @message = message.to_s.strip
  end

  def send_sms
    response = perform_request
    body = parse_response(response)
    validate_response!(response, body)
    true
  rescue StandardError => e
    raise NetworkCallError, "Failed to send SMS: #{e.message}"
  end

  private

  def perform_request
    uri = URI.parse(TEXTBEE_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = request_payload.to_json
    http.request(request)
  end

  def headers
    {
      'Content-Type' => 'application/json',
      'x-api-key' => API_KEY
    }
  end

  def request_payload
    {
      recipients: [formatted_number],
      message: @message
    }
  end

  def formatted_number
    @mobile.start_with?('+') ? @mobile : "#{COUNTRY_CODE}#{@mobile}"
  end

  def parse_response(response)
    JSON.parse(response.body)
  rescue JSON::ParserError
    raise NetworkCallError.new("Invalid JSON response from SMS gateway: #{response.body}")
  end

  def validate_response!(response, body)
    data = body["data"] || {}
    success = response.is_a?(Net::HTTPSuccess) && data["success"] == true
    raise NetworkCallError.new("SMS failed: #{body}") unless success
  end
end
