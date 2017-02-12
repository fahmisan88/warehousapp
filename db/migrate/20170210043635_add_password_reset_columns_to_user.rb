class AddPasswordResetColumnsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    remove_index :users, :password_reset_token
    remove_column :users, :password_reset_token, :string
  end
end
