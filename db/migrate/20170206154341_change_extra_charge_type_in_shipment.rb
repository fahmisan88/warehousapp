class ChangeExtraChargeTypeInShipment < ActiveRecord::Migration[5.0]
  def change
    change_column :shipments, :extra_charge, :integer
    change_column_default(:shipments, :extra_charge, 0)
  end
end
