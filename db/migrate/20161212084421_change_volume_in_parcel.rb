class ChangeVolumeInParcel < ActiveRecord::Migration[5.0]
  def change
    change_column :parcels, :volume, :decimal
  end
end
