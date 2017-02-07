class ChangeMinusChargeToShipment < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:shipments, :minus_charge, 0)
  end
end
