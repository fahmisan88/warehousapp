class ShipmentsController < ApplicationController
  before_action :authenticate!


  def index
    @filter_params = params[:status]
    @freight_params = params[:sea_freight]

    if admin_user || staff_user
      @shipments= Shipment.all.order(updated_at: :desc).page params[:page]
    else
      @shipments= current_user.shipments.order(updated_at: :desc).page params[:page]
    end

		if @filter_params == "Processing"
      if admin_user || staff_user
        @shipments = Shipment.where(status: 0).order("created_at desc").page(params[:page])
      else
        @shipments = current_user.shipments.where(status: 0).order("created_at desc").page(params[:page])
      end
    elsif @filter_params == "Awaiting Payment"
      if admin_user || staff_user
        @shipments = Shipment.where(status: 1).order("created_at desc").page(params[:page])
      else
        @shipments = current_user.shipments.where(status: 1).order("created_at desc").page(params[:page])
      end
		elsif @filter_params == "Paid"
      if admin_user || staff_user
        @shipments = Shipment.where(status: 2).order("created_at desc").page(params[:page])
      else
        @shipments = current_user.shipments.where(status: 2).order("created_at desc").page(params[:page])
      end
    end

		if @freight_params == "Air Freight"
      if admin_user || staff_user
        @shipments = Shipment.where(sea_freight: false).order("created_at desc").page(params[:page])
      else
        @shipments = current_user.shipments.where(sea_freight: false).order("created_at desc").page(params[:page])
      end
    elsif @freight_params == "Sea Freight"
      if admin_user || staff_user
        @shipments = Shipment.where(sea_freight: true).order("created_at desc").page(params[:page])
      else
        @shipments = current_user.shipments.where(sea_freight: true).order("created_at desc").page(params[:page])
      end
    end

    if params[:search]
      if admin_user || staff_user
        @shipments = Shipment.search(params[:search]).order("updated_at DESC").page params[:page]
      else
        @shipments = current_user.shipments.search(params[:search]).order("updated_at DESC").page params[:page]
      end
    end

  end

  def show
    @shipment = Shipment.find_by(id: params[:id])
    @currency = Currency.find_by(id: 1)
    authorize @shipment
  end

  def new
    @shipment= Shipment.new
    @parcels = current_user.parcels.where(status: 1)
  end

  def create
    @parcels= Parcel.where(id: params[:parcel_id])
    @shipment= current_user.shipments.build(shipment_params)
    finalKg = @parcels.sum(:final_kg).to_i
    authorize @shipment
    if @shipment.save
      @parcels.each do |parcel|
        @shipment.ordered_parcels.create( {:parcel_id => parcel.id})
        parcel.update({:status => :"Ready To Ship"})
      end
      if @parcels.sum(:parcel_good) >= 1
        @shipment.update_attributes(status: "Processing", :final_kg => finalKg, :shipment_type => 1 )
      else
        @shipment.update_attributes(status: "Processing", :final_kg => finalKg, :shipment_type => 0 )
      end
      flash[:success] = "You've post a shipment."
      # deliver_mail(current_user.name, current_user.email, "shipments", "created")
      redirect_to shipments_path
    else
      flash[:danger]
      redirect_to new_shipment_path
    end
  end

  def edit
    @shipment = Shipment.find(params[:id])
    @parcels = @shipment.parcels.where(status: 2)
    authorize @shipment
  end

  def update
    @shipment = Shipment.find(params[:id])
    authorize @shipment
    if @shipment.update(shipment_params)
      if @shipment.charge != nil
        @bill = Billplz.create_bill_for(@shipment)
        @shipment.update_attributes(bill_id: @bill.parsed_response['id'], bill_url: @bill.parsed_response['url'], status: "Awaiting Payment")
        # redirect_to @bill.parsed_response['url']
        flash[:success] ="Payment Request has been sent"
        @shipment_user = @shipment.user_id
        @user_info = User.find(@shipment_user)
        deliver_mail(@user_info.name, @user_info.email, "shipments", "waitpayment")
        redirect_to shipments_path
      else
        redirect_to shipments_path
      end
    else
      redirect_to shipments_path
      # flash[:danger]
    end
  end

  def destroy
    @shipment = Shipment.find(params[:id])
    authorize @shipment
    if @shipment.destroy
      flash[:success]= "You've cancelled your shipment."
      redirect_to shipments_path
    else
      flash[:danger]
      redirect_to shipments_path
    end
  end

  def statement
    if admin_user || staff_user
      @shipments= Shipment.all.where(status: 2).order(updated_at: :desc).page params[:page]
    else
      @shipments= current_user.shipments.where(status: 2).order(updated_at: :desc).page params[:page]
    end
  end

  private

  def shipment_params
    params.require(:shipment).permit(:status, :remark, :charge, :bill_id, :bill_url, :due_at, :paid_at, :reorganize, :repackaging, :sea_freight, :ezi_id)
  end

end
