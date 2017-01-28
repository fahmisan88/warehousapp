class ChangeColumnDateToUser < ActiveRecord::Migration[5.0]
  def change
    change_column_default(:users, :created_at, Time.now)
  end
end
