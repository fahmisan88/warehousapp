class ChangeDefaultValue < ActiveRecord::Migration[5.0]
  def change
    change_column_default :parcels, :weight, 0.5
    change_column_default :parcels, :width, 1
    change_column_default :parcels, :length, 1
    change_column_default :parcels, :height, 1
    change_column_default :parcels, :status, 0
  end
end
