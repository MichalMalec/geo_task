require 'rails_helper'
require 'webmock/rspec'

RSpec.describe IpstackService, type: :service do
  before do
    stub_request(:any, /api.ipstack.com/).to_return(
      status: 200,
      body: '{"ip": "8.8.8.8", "country_name": "United States"}',
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  describe '.get_geolocation' do
    context 'when the API responds successfully' do
      it 'returns parsed geolocation data' do
        ip_or_url = '8.8.8.8'
        geolocation = IpstackService.get_geolocation(ip_or_url)

        expect(geolocation).to include('ip')
        expect(geolocation['country_name']).to eq('United States')
      end
    end

    context 'when the API times out' do
      before do
        stub_request(:get, /api.ipstack.com/).to_timeout
      end

      it 'returns a timeout error message' do
        ip_or_url = '8.8.8.8'
        geolocation = IpstackService.get_geolocation(ip_or_url)

        expect(geolocation).to eq({ error: 'IPStack API is currently unavailable. Please try again later.' })
      end
    end

    context 'when the API responds with an error' do
      before do
        stub_request(:get, /api.ipstack.com/).to_return(status: 401, body: '{"error": "Unauthorized"}')
      end

      it 'returns an unauthorized error message' do
        ip_or_url = '8.8.8.8'
        geolocation = IpstackService.get_geolocation(ip_or_url)

        expect(geolocation).to eq({ error: 'Unauthorized access. Check your API key.' })
      end
    end

    context 'when the API returns an invalid response' do
      before do
        stub_request(:get, /api.ipstack.com/).to_return(status: 200, body: 'invalid json')
      end

      it 'returns a parsing error message' do
        ip_or_url = '8.8.8.8'
        geolocation = IpstackService.get_geolocation(ip_or_url)

        expect(geolocation).to eq({ error: 'Unable to process location data.' })
      end
    end

    context 'when the API returns a 500 error' do
      before do
        stub_request(:get, /api.ipstack.com/).to_return(status: 500, body: '{"error": "Internal Server Error"}')
      end

      it 'returns a service unavailable error message' do
        ip_or_url = '8.8.8.8'
        geolocation = IpstackService.get_geolocation(ip_or_url)

        expect(geolocation).to eq({ error: 'IPStack API is currently unavailable.' })
      end
    end
  end
end
