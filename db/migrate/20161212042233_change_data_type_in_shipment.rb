class ChangeDataTypeInShipment < ActiveRecord::Migration[5.0]
  def change
    change_column :shipments, :status, :string
  end
end
