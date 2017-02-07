class AddSeaChargeToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :sea_charge, :decimal
  end
end
