class AddCbmtransportToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :cbm, :string
    add_column :shipments, :transport_charge, :decimal
  end
end
