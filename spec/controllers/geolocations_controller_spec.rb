require 'rails_helper'

RSpec.describe GeolocationsController, type: :controller do
  let(:valid_attributes) do
    {
      ip: '8.8.8.8',
      url: 'https://www.example.com',
      country: 'United States',
      region: 'California',
      city: 'Mountain View',
      latitude: 37.4056,
      longitude: -122.0775
    }
  end

  let(:invalid_attributes) do
    {
      ip: nil,
      url: nil,
      country: nil,
      region: nil,
      city: nil,
      latitude: nil,
      longitude: nil
    }
  end

  let(:geolocation) { Geolocation.create!(valid_attributes) }

  before do
    allow(IpstackService).to receive(:get_geolocation).and_return(
      {
        'ip' => '8.8.8.8',
        'country_name' => 'United States',
        'region_name' => 'California',
        'city' => 'Mountain View',
        'latitude' => 37.4056,
        'longitude' => -122.0775
      }
    )
  end

  describe 'POST #create' do
    context 'when valid data is provided' do
      it 'creates a new geolocation' do
        expect {
          post :create, params: { ip: '8.8.8.8' }
        }.to change(Geolocation, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['ip']).to eq('8.8.8.8')
      end
    end

    context 'when invalid data is provided' do
      it 'returns an error message' do
        allow(IpstackService).to receive(:get_geolocation).and_return(nil)

        post :create, params: { ip: 'invalid_ip' }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Unable to fetch geolocation data')
      end
    end

    context 'when a database error occurs' do
      it 'returns an internal server error' do
        allow(IpstackService).to receive(:get_geolocation).and_return(
          {
            'ip' => '8.8.8.8',
            'country_name' => 'United States',
            'region_name' => 'California',
            'city' => 'Mountain View',
            'latitude' => 37.4056,
            'longitude' => -122.0775
          }
        )
        allow(Geolocation).to receive(:create!).and_raise(ActiveRecord::ActiveRecordError)

        post :create, params: { ip: '8.8.8.8' }

        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to match(/Database error:/)
      end
    end
  end

  describe 'GET #show' do
    context 'when geolocation exists' do
      it 'returns the geolocation' do
        get :show, params: { id: geolocation.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['ip']).to eq(geolocation.ip)
      end
    end

    context 'when geolocation does not exist' do
      it 'returns a not found error' do
        get :show, params: { id: 'nonexistent_id' }

        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq("Geolocation not found")
      end
    end
  end

  describe 'DELETE #destroy' do
  context 'when geolocation exists' do
    it 'destroys the geolocation' do
      geolocation = Geolocation.create!(valid_attributes)

      expect {
        delete :destroy, params: { id: geolocation.id }
      }.to change(Geolocation, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end

  context 'when geolocation does not exist' do
    it 'returns not found error' do
      delete :destroy, params: { id: 'nonexistent_id' }

      expect(response).to have_http_status(:not_found)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq("Geolocation not found")
    end
  end

  context 'when a database error occurs' do
    it 'returns an internal server error' do
      geolocation = Geolocation.create!(valid_attributes)

      allow(Geolocation).to receive(:find).and_raise(ActiveRecord::ActiveRecordError.new("Database error"))

      delete :destroy, params: { id: geolocation.id }

      expect(response).to have_http_status(:internal_server_error)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to match("Database error while fetching record: Database error")
    end
  end
end
end
