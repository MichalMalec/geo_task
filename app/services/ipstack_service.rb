require "httparty"

class IpstackService
  BASE_URL = "http://api.ipstack.com"
  ACCESS_KEY = ENV["IPSTACK_API_KEY"]

  def self.get_geolocation(ip_or_url)
    begin
      response = HTTParty.get("#{BASE_URL}/#{ip_or_url}?access_key=#{ACCESS_KEY}")

      if response.code == 200
        parse_json(response.body)
      else
        handle_api_error(response)
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      { error: "IPStack API is currently unavailable. Please try again later." }
    rescue JSON::ParserError => e
      { error: "Unable to process location data." }
    rescue StandardError => e
      { error: "An unknown error occurred." }
    end
  end

  private

  def self.parse_json(response_body)
    JSON.parse(response_body)
  rescue JSON::ParserError => e
    { error: "Unable to process location data." }
  end

  def self.handle_api_error(response)
    case response.code
    when 401
      { error: "Unauthorized access. Check your API key." }
    when 403
      { error: "Access forbidden. Check your API permissions." }
    when 404
      { error: "IP not found." }
    when 500..599
      { error: "IPStack API is currently unavailable." }
    else
      { error: "Unknown API error: #{response.code}" }
    end
  end
end
