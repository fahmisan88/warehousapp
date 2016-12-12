class Parcel < ApplicationRecord
  include PublicActivity::Common
  belongs_to :user
  has_many :ordered_parcels
  has_many :shipments, through: :ordered_parcels

  enum status: [:Pending, :Arrived, :"Ready To Ship", :Shipped]
  enum parcel_good: [:Normal, :Sensitive, :"I Dont Know"]

  mount_uploader :image, ImageUploader
  paginates_per 10

  def self.search(search)
    where("awb ILIKE ?", "%#{search}%")
  end
end
