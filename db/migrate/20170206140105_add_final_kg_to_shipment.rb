class AddFinalKgToShipment < ActiveRecord::Migration[5.0]
  def change
    add_column :shipments, :final_kg, :decimal
  end
end
