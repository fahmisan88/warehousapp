class DashboardsController < ApplicationController
  before_action :authenticate!

  def index
    if admin_user || staff_user
    @parcels = Parcel.where(status: 0)
    @shipments = Shipment.where(status: 0)
    @todaysale = Shipment.where(status: 2, updated_at:DateTime.now)
    @todaysales = Shipment.where(status: 2, updated_at:DateTime.now).limit(10)
    @totalsales= Shipment.where(status:2)
    @activities = PublicActivity::Activity.order("created_at desc").limit(7)
    else
      @totalsales= current_user.shipments.where(status:2)
      @todaysale = current_user.shipments.where(status: 2, updated_at:DateTime.now)
      @todaysales = current_user.shipments.where(status: 2, updated_at:DateTime.now).limit(10)
    @parcels= current_user.parcels
    @shipments= current_user.shipments
    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: current_user).limit(7)
  end
  @currency = Currency.find_by(id: 1)
  end
end
