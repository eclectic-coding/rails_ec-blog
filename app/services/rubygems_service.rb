require "net/http"
require "json"

class RubygemsService
  CACHE_TTL = 1.hour

  def self.gems
    Rails.cache.fetch("rubygems/#{username}/gems", expires_in: CACHE_TTL) { fetch_gems }
  end

  def self.fetch_gems
    url = URI("https://rubygems.org/api/v1/owners/#{username}/gems.json")
    response = Net::HTTP.get_response(url)
    return [] unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue StandardError
    []
  end

  def self.username
    Rails.application.credentials.dig(:rubygems, :username) ||
      ENV.fetch("RUBYGEMS_USERNAME", nil)
  end
end
