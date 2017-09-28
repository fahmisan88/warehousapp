class DashboardsController < ApplicationController
  before_action :authenticate!

  def index
    @totalsales= current_user.shipments.where(status: 2)
    @todaysale2 = current_user.shipments.where(status: 1).limit(10)
    @pendingpayment = current_user.shipments.where(status: 1)
    @todaysale = current_user.shipments.where(status: 2, updated_at:DateTime.now)
    @todaysales = current_user.shipments.where(status: 2, updated_at:DateTime.now).limit(10)
    @parcels= current_user.parcels.where(status:1)
    @shipments= current_user.shipments
    @currency = Currency.find_by(id: 1)
  end
end
