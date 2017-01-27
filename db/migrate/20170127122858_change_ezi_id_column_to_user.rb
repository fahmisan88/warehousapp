class ChangeEziIdColumnToUser < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :ezi_id, :integer, :unique => true
    add_index :users, :ezi_id
  end
end
