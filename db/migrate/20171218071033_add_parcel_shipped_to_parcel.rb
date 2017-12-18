class AddParcelShippedToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :parcel_shipped, :datetime
  end
end
