class GeolocationsController < ApplicationController
  before_action :set_geolocation, only: [:show, :destroy]

  def create
    ip_or_url = params[:ip] || params[:url]
    geolocation_data = IpstackService.get_geolocation(ip_or_url)

    if geolocation_data
      @geolocation = Geolocation.create(
        ip: geolocation_data['ip'],
        url: params[:url],
        country: geolocation_data['country_name'],
        region: geolocation_data['region_name'],
        city: geolocation_data['city'],
        latitude: geolocation_data['latitude'],
        longitude: geolocation_data['longitude']
    )
      render json: @geolocation, status: :created
    else
      render json: { error: 'Unable to fetch geolocation data' }, status: :unprocessable_entity
    end
  end

  def show
    render json: @geolocation
  end

  def destroy
    @geolocation.destroy
    head :no_content
  end

  private

  def set_geolocation
    @geolocation = Geolocation.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Geolocation not found' }, status: :not_found
  end
end
  