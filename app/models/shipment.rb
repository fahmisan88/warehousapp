class Shipment < ApplicationRecord
  has_many :parcels, through: :ordered_parcels
  has_many :ordered_parcels, dependent: :destroy
  belongs_to :user

  enum status: [:Processing, :"Awaiting Payment", :Paid]

  before_destroy :update_status, prepend: true
end
