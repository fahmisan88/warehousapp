class AddParcelArrivedToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :parcel_arrived, :datetime
    add_column :shipments, :storage_charge, :decimal
  end
end
