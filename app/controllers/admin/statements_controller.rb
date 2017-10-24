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
    respond_to do |format|
      format.html do
        render layout: false
      end
      format.pdf do
        render  pdf: "invoice", template: 'admin/statements/invoice.pdf.erb'
      end
    end
  end

end
