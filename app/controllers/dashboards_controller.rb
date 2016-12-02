class DashboardsController < ApplicationController
  before_action :authenticate!

  def index
    if admin_user || staff_user
    @parcels = Parcel.where(status: 0)
    @shipments = Shipment.where(status: 0)
    @todaysales = Shipment.where(status: 2, updated_at:DateTime.now)
    @totalsales= Shipment.where(status:2)
    @currency = Currency.find_by(id: 1)
    else
    @parcels= current_user.parcels
    @shipments= current_user.shipments
  end
  end
end
