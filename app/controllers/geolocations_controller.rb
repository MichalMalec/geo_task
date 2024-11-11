class GeolocationsController < ApplicationController
  before_action :set_geolocation, only: [:show, :destroy]

  def create
    ip_or_url = params[:ip] || params[:url]
    geolocation_data = IpstackService.get_geolocation(ip_or_url)

    if geolocation_data
      begin
        @geolocation = Geolocation.create!(
          ip: geolocation_data['ip'],
          url: params[:url],
          country: geolocation_data['country_name'],
          region: geolocation_data['region_name'],
          city: geolocation_data['city'],
          latitude: geolocation_data['latitude'],
          longitude: geolocation_data['longitude']
        )
        render json: @geolocation, status: :created
      rescue ActiveRecord::ActiveRecordError => e
        render json: { error: "Database error: #{e.message}" }, status: :internal_server_error
      end
    else
      render json: { error: 'Unable to fetch geolocation data' }, status: :unprocessable_entity
    end
  end

  def show
    render json: @geolocation
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Geolocation not found: #{e.message}" }, status: :not_found
  end

  def destroy
    begin
      @geolocation.destroy!
      head :no_content
    rescue ActiveRecord::RecordNotFound => e
      render json: { error: "Geolocation not found: #{e.message}" }, status: :not_found
    rescue ActiveRecord::ActiveRecordError => e
      render json: { error: "Database error while deleting record: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  def set_geolocation
    @geolocation = Geolocation.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Geolocation not foundg" }, status: :not_found
  rescue ActiveRecord::ActiveRecordError => e
    render json: { error: "Database error while fetching record: #{e.message}" }, status: :internal_server_error
  end
end
