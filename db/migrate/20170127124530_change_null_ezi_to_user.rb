class ChangeNullEziToUser < ActiveRecord::Migration[5.0]
  def change
    change_column_null :users, :ezi_id, true
    change_column_default :users, :ezi_id, nil
  end
end
