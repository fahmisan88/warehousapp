class ChangePostcodeToUser < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :postcode, :string
  end
end
