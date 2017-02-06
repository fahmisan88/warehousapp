class AddFinalKgToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :final_kg, :decimal
  end
end
