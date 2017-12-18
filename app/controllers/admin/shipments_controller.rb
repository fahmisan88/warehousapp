class Admin::ShipmentsController < ApplicationController
  before_action :check_if_admin


  # def index
  #   @shipments= Shipment.all.order(updated_at: :desc).page(params[:page]).per(15)
  #   @filter_params = params[:status]
	# 	if @filter_params == "Processing"
  #     @shipments = Shipment.where(status: 0).order("created_at desc").page(params[:page]).per(15)
  #   elsif @filter_params == "Awaiting Payment"
  #     @shipments = Shipment.where(status: 1).order("created_at desc").page(params[:page]).per(15)
	# 	elsif @filter_params == "Paid"
  #     @shipments = Shipment.where(status: 2).order("created_at desc").page(params[:page]).per(15)
  #   end
  #   if params[:search]
  #     @shipments = Shipment.search(params[:search]).order("updated_at DESC").page(params[:page]).per(15)
  #   end
  # end

  def air
    @shipments = Shipment.where(sea_freight: false).order("updated_at desc").page(params[:page]).per(20)
    @filter_params = params[:status]
    if @filter_params == "Processing"
      @shipments = Shipment.where(status: 0, sea_freight: false).order("created_at desc").page(params[:page]).per(20)
    elsif @filter_params == "Awaiting Payment"
      @shipments = Shipment.where(status: 1, sea_freight: false).order("created_at desc").page(params[:page]).per(20)
		elsif @filter_params == "Paid"
      @shipments = Shipment.where(status: 2, sea_freight: false).order("created_at desc").page(params[:page]).per(20)
    end
    if params[:search]
      @shipments = Shipment.where(sea_freight: false).search(params[:search]).order("updated_at DESC").page(params[:page]).per(20)
    end
  end

  def sea
    @shipments = Shipment.where(sea_freight: true).order("updated_at desc").page(params[:page]).per(20)
    @filter_params = params[:status]
    if @filter_params == "Processing"
      @shipments = Shipment.where(status: 0, sea_freight: true).order("created_at desc").page(params[:page]).per(20)
    elsif @filter_params == "Awaiting Payment"
      @shipments = Shipment.where(status: 1, sea_freight: true).order("created_at desc").page(params[:page]).per(20)
		elsif @filter_params == "Paid"
      @shipments = Shipment.where(status: 2, sea_freight: true).order("created_at desc").page(params[:page]).per(20)
    end
    if params[:search]
      @shipments = Shipment.where(sea_freight: true).search(params[:search]).order("updated_at DESC").page(params[:page]).per(20)
    end
  end

  def show
    @shipment = Shipment.find_by(id: params[:id])
    @currency = Currency.find_by(id: 1)
    @charged_storages = @shipment.parcels.where("? > free_storage", Time.now)
  end

  def edit
    @shipment = Shipment.find(params[:id])
    @parcels = @shipment.parcels.where(status: 2)
  end

  def edit_sea
    @shipment = Shipment.find(params[:id])
    @parcels = @shipment.parcels.where(status: 2)
  end

  def update
    @shipment = Shipment.find(params[:id])
    authorize @shipment
    if !@shipment.charge.nil? || !@shipment.charge.blank?
      @bill = Billplz.create_bill_for(@shipment)
      @shipment.update_attributes(bill_id: @bill.parsed_response['id'], bill_url: @bill.parsed_response['url'], status: "Awaiting Payment")
      # redirect_to @bill.parsed_response['url']
      flash[:success] ="Payment Request has been sent"
      @shipment_user = @shipment.user_id
      @user_info = User.find(@shipment_user)
      deliver_mail(@user_info.name, @user_info.email, "shipments", "waitpayment")
    else
      flash[:danger] = "Please calculate the cost of shipment first"
    end
    redirect_to admin_shipment_path(@shipment)
  end

  def calculate
    @shipment = Shipment.find(params[:id])
    @currency = Currency.find_by(id: 1)
    @charged_storages = @shipment.parcels.where("? > free_storage", Time.now)
    @ringgit = @currency.myr2rmb

    chargePhotoshoot = (@shipment.parcels.where(photoshoot: true).size * 10 / @ringgit).ceil(1)
    chargeInspection = (@shipment.parcels.where(inspection: true).size * 30 / @ringgit).ceil(1)
    extraCharge = (params[:shipment][:extra_charge].to_d / @ringgit).ceil(1)
    minusCharge = (params[:shipment][:minus_charge].to_d / @ringgit).ceil(1)
    airCharge = params[:shipment][:air_charge].to_d

    if @charged_storages.present?
      storageCharge = 0
      @charged_storages.each do |c|
        charge = (((Time.now - c.free_storage) / 3600 / 24).round * 5 / @ringgit).ceil(1)
        storageCharge += charge
      end
    else
      storageCharge = 0
    end

    if params[:shipment][:reorganize] == "true"
      chargeReorganize = (@shipment.parcels.size * 2 / @ringgit).ceil(1)
    else
      chargeReorganize = 0
    end

    if params[:shipment][:repackaging] == "true"
      chargeRepackaging = (10 / @ringgit).ceil(1)
    else
      chargeRepackaging = 0
    end

    chargeMYR = (airCharge + extraCharge + chargeReorganize + chargeRepackaging + chargePhotoshoot + chargeInspection + storageCharge - minusCharge).ceil(1)
    @shipment.update(charge: chargeMYR, repackaging: calculate_params[:repackaging], reorganize: calculate_params[:reorganize],
                      extra_charge: calculate_params[:extra_charge], minus_charge: calculate_params[:minus_charge], extra_remark: calculate_params[:extra_remark],
                      remark_admin: calculate_params[:remark_admin], air_charge: calculate_params[:air_charge], storage_charge: storageCharge
                    )
    flash[:success] ="Calculate successfully"
    redirect_to admin_shipment_path(@shipment)

  end

  def sea_calculate
    @shipment = Shipment.find(params[:id])
    @currency = Currency.find_by(id: 1)
    @charged_storages = @shipment.parcels.where("? > free_storage", Time.now)
    @ringgit = @currency.myr2rmb

    chargePhotoshoot = (@shipment.parcels.where(photoshoot: true).size * 10 / @ringgit).ceil(1)
    chargeInspection = (@shipment.parcels.where(inspection: true).size * 30 / @ringgit).ceil(1)
    extraCharge = (params[:shipment][:extra_charge].to_d / @ringgit).ceil(1)
    minusCharge = (params[:shipment][:minus_charge].to_d / @ringgit).ceil(1)
    seaCharge = params[:shipment][:sea_charge].to_d

    if @charged_storages.present?
      storageCharge = 0
      @charged_storages.each do |c|
        charge = (((Time.now - c.free_storage) / 3600 / 24).round * 5 / @ringgit).ceil(1)
        storageCharge += charge
      end
    else
      storageCharge = 0
    end

    if params[:shipment][:reorganize] == "true"
      chargeReorganize = (@shipment.parcels.size * 2 / @ringgit).ceil(1)
    else
      chargeReorganize = 0
    end

    if params[:shipment][:repackaging] == "true"
      chargeRepackaging = (10 / @ringgit).ceil(1)
    else
      chargeRepackaging = 0
    end

    if params[:shipment][:transport_charge] == ""
      chargeTransport = 0
    else
      chargeTransport = params[:shipment][:transport_charge].to_d
    end

    chargeMYR = (seaCharge + extraCharge + chargeReorganize + chargeRepackaging + chargePhotoshoot + chargeInspection + chargeTransport + storageCharge - minusCharge).ceil(1)
    @shipment.update(charge: chargeMYR, repackaging: sea_calculate_params[:repackaging], reorganize: sea_calculate_params[:reorganize],
                      extra_charge: sea_calculate_params[:extra_charge], minus_charge: sea_calculate_params[:minus_charge], extra_remark: sea_calculate_params[:extra_remark],
                      remark_admin: sea_calculate_params[:remark_admin], sea_charge: sea_calculate_params[:sea_charge], cbm: sea_calculate_params[:cbm], transport_charge: sea_calculate_params[:transport_charge],
                      storage_charge: storageCharge
                    )
    flash[:success] ="Sea Charge Submitted"
    redirect_to admin_shipment_path(@shipment)

  end

  def statement
    @shipments= Shipment.all.where(status: 2).order(updated_at: :desc).page params[:page]
  end

  def update_tracking
    @shipment = Shipment.find(params[:id])
    if @shipment.update tracking_params
      flash[:success] = "You successfully added a tracking number"
    else
      flash[:danger] = "Failed to add tracking number"
    end
    redirect_to admin_shipment_path(@shipment)
  end

  def update_status
    @shipment = Shipment.find(params[:id])
    if @shipment.update change_status_params
      flash[:success] = "You successfully update the status"
    else
      flash[:danger] = "Failed to update status"
    end
    redirect_to admin_shipment_path(@shipment)
  end

  def invoice
    @shipment = Shipment.find(params[:id])
    render layout: false
  end

  def destroy
    @shipment = Shipment.find(params[:id])
    if @shipment.sea_freight?
      if @shipment.destroy
        flash[:success]= "Shipment successfully deleted"
        redirect_to sea_admin_shipments_path
      else
        flash[:danger]
        redirect_to sea_admin_shipments_path
      end
    else
      if @shipment.destroy
        flash[:success]= "Shipment successfully deleted"
        redirect_to air_admin_shipments_path
      else
        flash[:danger]
        redirect_to air_admin_shipments_path
      end
    end
  end

  private

  def shipment_params
    params.require(:shipment).permit(:status, :remark, :charge, :bill_id, :bill_url, :due_at, :paid_at, :reorganize, :repackaging, :sea_freight, :ezi_id)
  end

  def calculate_params
    params.require(:shipment).permit(:air_charge, :repackaging, :reorganize, :extra_charge, :extra_remark, :minus_charge, :remark_admin, :storage_charge)
  end

  def sea_calculate_params
    params.require(:shipment).permit(:sea_charge, :repackaging, :reorganize, :extra_charge, :extra_remark, :minus_charge, :remark_admin, :cbm, :transport_charge, :storage_charge)
  end

  def tracking_params
    params.require(:shipment).permit(:tracking)
  end

  def change_status_params
    params.require(:shipment).permit(:status)
  end

end
