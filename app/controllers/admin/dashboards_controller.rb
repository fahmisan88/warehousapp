class Admin::DashboardsController < ApplicationController
  before_filter :check_if_admin

  def index
    @parcels    = Parcel.where(status: 0)
    @shipments  = Shipment.where(status: 0)
    @todaysale  = Shipment.where(status: 2, updated_at:DateTime.now)
    @todaysale2 = Shipment.where(status: 1).limit(6)
    @todaysales = Shipment.where(status: 2, updated_at:DateTime.now).limit(6)
    @totalsales = Shipment.where(status: 2).sum(:charge).floor
    @currency   = Currency.find_by(id: 1)
  end
end
