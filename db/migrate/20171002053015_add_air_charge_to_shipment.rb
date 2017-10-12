class AddAirChargeToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :air_charge, :decimal
  end
end
