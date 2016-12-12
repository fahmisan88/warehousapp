class AddCalculationToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :width, :decimal
    add_column :parcels, :length, :decimal
    add_column :parcels, :height, :decimal
  end
end
