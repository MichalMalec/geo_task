class CreateGeolocations < ActiveRecord::Migration[7.2]
  def change
    create_table :geolocations do |t|
      t.string :ip
      t.string :url
      t.string :country
      t.string :region
      t.string :city
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
