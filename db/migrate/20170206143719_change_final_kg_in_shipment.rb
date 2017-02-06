class ChangeFinalKgInShipment < ActiveRecord::Migration[5.0]
  def change
    change_column :shipments, :final_kg, :integer
  end
end
