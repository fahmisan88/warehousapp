class Shipment < ApplicationRecord
  include PublicActivity::Common

  has_many :parcels, through: :ordered_parcels
  has_many :ordered_parcels, dependent: :destroy
  belongs_to :user

  enum status: [:Processing, :"Awaiting Payment", :Paid]

  before_destroy :update_status, prepend: true
  paginates_per 10


# searching not yet done properly
  def self.search(search)
    where("status = ?", Shipment.statuses[:Paid])
    where("status = ?", Shipment.statuses[:"Awaiting Payment"])
    where("status = ?", Shipment.statuses[:Processing])
  end

end
