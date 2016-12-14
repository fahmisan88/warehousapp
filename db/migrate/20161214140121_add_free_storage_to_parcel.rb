class AddFreeStorageToParcel < ActiveRecord::Migration[5.0]
  def change
    add_column :parcels, :free_storage, :datetime
  end
end
