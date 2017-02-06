class DashboardsController < ApplicationController
  before_action :authenticate!

  def index
    if admin_user || staff_user
    @parcels = Parcel.where(status: 0)
    @shipments = Shipment.where(status: 0)
    @todaysale = Shipment.where(status: 2, updated_at:DateTime.now)
    @todaysale2 = Shipment.where(status: 1).limit(10)
    @todaysales = Shipment.where(status: 2, updated_at:DateTime.now).limit(10)
    @totalsales= Shipment.where(status: 2)
    else
      @totalsales= current_user.shipments.where(status: 2)
      @todaysale2 = current_user.shipments.where(status: 1).limit(10)
      @pendingpayment = current_user.shipments.where(status: 1)
      @todaysale = current_user.shipments.where(status: 2, updated_at:DateTime.now)
      @todaysales = current_user.shipments.where(status: 2, updated_at:DateTime.now).limit(10)
    @parcels= current_user.parcels.where(status:1)
    @shipments= current_user.shipments
  end
  @currency = Currency.find_by(id: 1)
  end
end
