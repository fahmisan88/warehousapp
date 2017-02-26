class Shipment < ApplicationRecord
  has_many :parcels, through: :ordered_parcels
  has_many :ordered_parcels, dependent: :destroy
  belongs_to :user

  enum status: [:Processing, :"Awaiting Payment", :Paid]
  enum shipment_type: [:Normal, :Sensitive]


  before_destroy :update_status, prepend: true
  paginates_per 10



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
    where(sea_freight: false)
  end

  def self.search4(search4)
    where(sea_freight: true)
  end


end
