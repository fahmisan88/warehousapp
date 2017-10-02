class DashboardsController < ApplicationController
  before_action :authenticate!

  def index
    @pendingpayment = current_user.shipments.where(status: 1)
    @recent_payments = current_user.shipments.where(status: 2).limit(6).order(updated_at: :desc)
    @parcels= current_user.parcels.where(status:1)
    @shipments = current_user.shipments.where(status:2)
    @recent_shipments = current_user.shipments.where(status:2).limit(6).order(updated_at: :desc)
    @currency = Currency.find_by(id: 1)
  end
end
