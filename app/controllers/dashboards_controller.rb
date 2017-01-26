class DashboardsController < ApplicationController
  before_action :authenticate!

  def index
    if admin_user || staff_user
    @parcels = Parcel.where(status: 0)
    @shipments = Shipment.where(status: "Processing")
    @todaysale = Shipment.where(status: "Shipped", updated_at:DateTime.now)
    @todaysale2 = Shipment.where(status: "Awaiting Payment").limit(10)
    @todaysales = Shipment.where(status: "Shipped", updated_at:DateTime.now).limit(10)
    @totalsales= Shipment.where(status:"Shipped")
    else
      @totalsales= current_user.shipments.where(status: "Shipped")
      @todaysale2 = current_user.shipments.where(status: "Awaiting Payment").limit(10)
      @pendingpayment = current_user.shipments.where(status: "Awaiting Payment")
      @todaysale = current_user.shipments.where(status: "Shipped", updated_at:DateTime.now)
      @todaysales = current_user.shipments.where(status: "Shipped", updated_at:DateTime.now).limit(10)
    @parcels= current_user.parcels.where(status:1)
    @shipments= current_user.shipments
  end
  @currency = Currency.find_by(id: 1)
  end
end
