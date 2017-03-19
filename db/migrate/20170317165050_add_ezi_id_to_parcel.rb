class AddEziIdToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :ezi_id, :string
  end
end
