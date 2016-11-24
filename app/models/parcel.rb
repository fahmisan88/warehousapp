class Parcel < ApplicationRecord
  belongs_to :user
  has_many :ordered_parcels
  has_many :shipments, through: :ordered_parcels

  enum status: [:Pending, :Arrived, :"Ready To Ship", :Shipped]
  enum parcel_good: [:Normal, :Sensitive]
end
