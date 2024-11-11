require 'httparty'

class IpstackService
  BASE_URL = "http://api.ipstack.com"
  ACCESS_KEY = ENV['IPSTACK_API_KEY']

  def self.get_geolocation(ip_or_url)
    response = HTTParty.get("#{BASE_URL}/#{ip_or_url}?access_key=#{ACCESS_KEY}")
    response.parsed_response if response.code == 200
  end
end
