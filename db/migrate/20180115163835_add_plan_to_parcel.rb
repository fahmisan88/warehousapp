class AddPlanToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :plan, :integer
  end
end
