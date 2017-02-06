class ChangeStatusTypeInShipment < ActiveRecord::Migration[5.0]
  def change
    change_column :shipments, :status, 'integer USING CAST(status AS integer)'
  end
end
