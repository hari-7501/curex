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
        currency_rates = data[currency].slice(*CURRENCIES)
        results[currency] = currency_rates
      end
    end

    pool.shutdown
    pool.wait_for_termination

    results.each do |currency, currency_rates|
      RedisService.hset("currency_rates:#{currency}", currency_rates)
      RedisService.expire("currency_rates:#{currency}", EXPIRY)
    end

    RedisService.set("currency_rates:last_updated", Time.now.to_s)
    results
  end

  private

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
