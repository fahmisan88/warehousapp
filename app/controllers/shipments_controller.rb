class ShipmentsController < ApplicationController
  before_action :authenticate!


  def index
    if admin_user || staff_user
    @shipments= Shipment.all.order(updated_at: :desc).page params[:page]
    else
    @shipments= current_user.shipments.order(updated_at: :desc).page params[:page]
    end

    if params[:search]
      if admin_user || staff_user
      @shipments = Shipment.search(params[:search]).order("updated_at DESC").page params[:page]
      else
      @shipments = current_user.shipments.search(params[:search]).order("updated_at DESC").page params[:page]
    end
    else
    end

  end

  def show
    @shipment = Shipment.find_by(id: params[:id])
    authorize @shipment
  end

  def new
    @shipment= Shipment.new
    @parcels = current_user.parcels.where(status: 1)
  end

  def create
    @parcels= Parcel.where(id: params[:parcel_id])
    @shipment= current_user.shipments.build(shipment_params)
    valvolume = @parcels.sum(:volume)
    valweight = @parcels.sum(:weight)
    valchargeable = @parcels.sum(:chargeable)
    authorize @shipment
    if @shipment.save
      @shipment.create_activity :create, owner: current_user
      @parcels.each do |parcel|
      @shipment.ordered_parcels.create( {:parcel_id => parcel.id})
      parcel.update({:status => :"Ready To Ship"})
      end
      if @parcels.sum(:parcel_good) >= 1
      @shipment.update_attributes(status: "Processing", :volume => valvolume, :weight => valweight, :chargeable => valchargeable, :shipment_type => 1 )
      else
        @shipment.update_attributes(status: "Processing", :volume => valvolume, :weight => valweight, :chargeable => valchargeable, :shipment_type => 0 )
      end
      flash[:success] = "You've post a shipment."
      redirect_to shipments_path
    else
      flash[:danger]
      redirect_to new_shipment_path
    end
  end

  def edit
    @shipment = Shipment.find(params[:id])
    authorize @shipment
  end

  def update
      @shipment = Shipment.find(params[:id])
      authorize @shipment
      if @shipment.update(shipment_params)
        if @shipment.charge != nil
        @bill = Billplz.create_bill_for(@shipment)
        @shipment.update_attributes(bill_id: @bill.parsed_response['id'], bill_url: @bill.parsed_response['url'], status: "Awaiting Payment")
        @shipment.create_activity :update, owner: current_user
        # redirect_to @bill.parsed_response['url']
        flash[:success] ="Payment Request has been sent"
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
      @shipments= Shipment.all.where(status: 'Paid').order(updated_at: :desc).page params[:page]
      else
      @shipments= current_user.shipments.where(status: 'Paid').order(updated_at: :desc).page params[:page]
      end

    end

  private

    def shipment_params
      params.require(:shipment).permit(:status, :remark, :weight, :volume, :charge, :bill_id, :bill_url, :due_at, :paid_at, :reorganize, :repackaging)
    end


end
