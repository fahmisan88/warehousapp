class AddMinusChargeToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :minus_charge, :integer
  end
end
