class RemoveReorganizeFromParcel < ActiveRecord::Migration[5.0]
  def change
    remove_column :parcels, :reorganize, :boolean
  end
end
