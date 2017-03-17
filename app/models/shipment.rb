class Shipment < ApplicationRecord
  has_many :parcels, through: :ordered_parcels
  has_many :ordered_parcels, dependent: :destroy
  belongs_to :user

  enum status: [:Processing, :"Awaiting Payment", :Paid]
  enum shipment_type: [:Normal, :Sensitive]


  before_destroy :update_status, prepend: true
  paginates_per 10

  def self.search(search)
      where('ezi_id ILIKE :search', search: "%#{search}%")
  end

end
