class ChangeColumnEziIdToUser < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :ezi_id, :string
  end
end
