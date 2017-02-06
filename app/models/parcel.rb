class Parcel < ApplicationRecord
  strip_attributes only: [:awb, :new_awb]
  belongs_to :user
  has_many :ordered_parcels
  has_many :shipments, through: :ordered_parcels

  enum status: [:Waiting, :Arrived, :"Ready To Ship", :Shipped, :"Request Refund", :Refunding, :Refunded]
  enum parcel_good: [:Normal, :Sensitive, :"I Dont Know"]

  mount_uploader :image, ImageUploader
  mount_uploader :image1, ImageUploader
  mount_uploader :image2, ImageUploader
  mount_uploader :image3, ImageUploader
  mount_uploader :image4, ImageUploader
  mount_uploader :image5, ImageUploader

  validates :image, file_size: { less_than_or_equal_to: 1.megabyte,
                                  message: "image should be less than or equal to 1mb" }
  paginates_per 10

  def self.search(search)
    where("awb ILIKE ?", "%#{search}%")
  end

  def self.search0(search0)
    where(status: 0)
  end

  def self.search1(search1)
    where(status: 1)
  end

  def self.search2(search2)
    where(status: 2)
  end

  def self.search3(search3)
    where(status: 3)
  end

  def self.search4(search4)
    where(status: 4)
  end

  def self.search5(search5)
    where(status: 5)
  end

  def self.search6(search6)
    where(status: 6)
  end
end
