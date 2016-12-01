class Parcel < ApplicationRecord
  belongs_to :user
  has_many :ordered_parcels
  has_many :shipments, through: :ordered_parcels

  enum status: [:Pending, :Arrived, :"Ready To Ship", :Shipped]
  enum parcel_good: [:Normal, :Sensitive]

  mount_uploader :image, ImageUploader
  paginates_per 10

  def self.search(search)
    where("awb ILIKE ?", "%#{search}%")
  end
end
