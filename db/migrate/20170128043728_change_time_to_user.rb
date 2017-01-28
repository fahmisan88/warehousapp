class ChangeTimeToUser < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:users, :created_at, nil)
    change_column_default(:users, :updated_at, nil)
  end
end
