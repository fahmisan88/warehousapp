class Admin::StatementsController < ApplicationController
  before_action :check_if_admin

  def index
    @shipments= Shipment.where(status: 2).order(updated_at: :desc).page(params[:page]).per(20)
    if params[:search]
      @shipments = Shipment.where(status: 2).search(params[:search]).order("updated_at DESC").page(params[:page]).per(20)
    end
  end

  def invoice
    @shipment = Shipment.find(params[:id])
    render layout: false
  end

end
