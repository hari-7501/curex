require "net/http"
require "json"
require "concurrent"

class CurrencyMatrixService
  BASE_URL = "https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies"
  CURRENCIES = %w[inr usd gbp jpy eur].freeze
  EXPIRY = 86_400

  def self.refresh_matrix
    pool = Concurrent::FixedThreadPool.new(5)
    results = {}

    CURRENCIES.each do |currency|
      pool.post do
        data = fetch_currency(currency)
        rates = data[currency].slice(*CURRENCIES)
        results[currency] = rates
      end
    end

    pool.shutdown
    pool.wait_for_termination

    results.each do |currency, rates|
      RedisService.hset("rates:#{currency}", rates)
      RedisService.expire("rates:#{currency}", EXPIRY)
    end

    results
  end

  def self.fetch_currency(currency)
    uri = URI("#{BASE_URL}/#{currency}.json")
    response = Net::HTTP.get_response(uri)
    raise "Failed for #{currency}" unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error("Currency fetch failed: #{e.message}")
    { currency => {} }
  end
end
