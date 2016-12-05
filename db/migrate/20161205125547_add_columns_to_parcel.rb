class AddColumnsToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :photoshoot, :boolean
    add_column :parcels, :inspection, :boolean
    add_column :parcels, :reorganize, :boolean
    add_column :parcels, :repackaging, :boolean
  end
end
