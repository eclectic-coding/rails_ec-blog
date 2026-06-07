require "net/http"
require "json"

class RubygemsService
  CACHE_KEY = "rubygems/eclecticCoding/gems"
  CACHE_TTL = 1.hour
  API_URL   = URI("https://rubygems.org/api/v1/owners/eclecticCoding/gems.json")

  def self.gems
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) { fetch_gems }
  end

  def self.fetch_gems
    response = Net::HTTP.get_response(API_URL)
    return [] unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError
    []
  end
end
