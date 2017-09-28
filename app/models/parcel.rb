class Parcel < ApplicationRecord
  strip_attributes only: [:awb, :new_awb]
  belongs_to :user
  has_many :ordered_parcels
  has_many :shipments, through: :ordered_parcels

  enum status: [:Waiting, :Arrived, :"Ready To Ship", :Shipped, :"Request Refund", :"Refund Rejected", :Refunded, :"need user action"]
  enum parcel_good: [:Normal, :Sensitive, :"I Dont Know"]

  mount_uploader :image, ImageUploader
  mount_uploaders :images, ImageUploader

  validates :image, file_size: { less_than_or_equal_to: 1.megabyte,
                                  message: "image should be less than or equal to 1mb" }
  paginates_per 10

  def self.search(search)
    where('awb ILIKE :search OR new_awb ILIKE :search', search: "%#{search}%")
  end

  def self.search_ezi(search)
    where('ezi_id ILIKE :search_ezi', search_ezi: "%#{search}%")
  end

end
