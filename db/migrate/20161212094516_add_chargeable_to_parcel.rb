class AddChargeableToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :chargeable, :decimal
  end
end
