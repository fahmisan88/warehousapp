class ChangeWeightInParcel < ActiveRecord::Migration[5.0]
  def change
    change_column :parcels, :weight, :decimal
  end
end
