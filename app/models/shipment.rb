class Shipment < ApplicationRecord
  has_many :parcels, through: :ordered_parcels
  has_many :ordered_parcels
  belongs_to :user

  enum status: [:Processing, :"Awaiting Payment", :Paid]
end
