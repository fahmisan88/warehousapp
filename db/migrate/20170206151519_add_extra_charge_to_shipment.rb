class AddExtraChargeToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :extra_charge, :decimal
  end
end
