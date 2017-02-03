class AddSeaFreightToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :sea_freight, :boolean, :default => false
  end
end
