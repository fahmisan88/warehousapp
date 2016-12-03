class Shipment < ApplicationRecord
  include PublicActivity::Common
  
  has_many :parcels, through: :ordered_parcels
  has_many :ordered_parcels, dependent: :destroy
  belongs_to :user

  enum status: [:Processing, :"Awaiting Payment", :Paid]

  before_destroy :update_status, prepend: true
  paginates_per 10



  # def self.search(search)
  #   where("id", "%#{search}%") ----> need to add shipping tracking id, cannot search id directly
  # end

end
