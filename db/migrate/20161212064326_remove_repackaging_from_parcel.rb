class RemoveRepackagingFromParcel < ActiveRecord::Migration[5.0]
  def change
    remove_column :parcels, :repackaging, :boolean
  end
end
