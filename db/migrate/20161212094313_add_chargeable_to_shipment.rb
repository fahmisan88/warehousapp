class AddChargeableToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :chargeable, :decimal
  end
end
