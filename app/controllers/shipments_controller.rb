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
      deliver_mail(current_user.name, current_user.email, "shipments", "created")
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

  def calculate
    @shipment = Shipment.find(params[:id])
    @currency = Currency.find_by(id: 1)
    @ringgit = @currency.rmb2myr

    chargeReorganize = @shipment.parcels.size * 2 * @ringgit
    chargeRepackaging = @shipment.parcels.size * 5 * @ringgit
    chargePhotoshoot = @shipment.parcels.where(photoshoot: true).size * 10
    chargeInspection = @shipment.parcels.where(inspection: true).size * 30

    chargeByWeight0To3 = (@shipment.weight * 30 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByWeight3To10 = (@shipment.weight * 26 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByWeight10above = (@shipment.weight * 23 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByVolume0To3 = (@shipment.chargeable.to_i * 30 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByVolume3To10 = (@shipment.chargeable.to_i * 26 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByVolume10above = (@shipment.chargeable.to_i * 23 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByWeight0To11ToSS = (@shipment.weight * 41 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByWeight11aboveToSS = (@shipment.weight * 38 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByVolume0To11ToSS = (@shipment.chargeable.to_i * 41 + chargePhotoshoot + chargeInspection) * @ringgit
    chargeByVolume11aboveToSS = (@shipment.chargeable.to_i * 38 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight0To2 = (@shipment.weight * 56 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight2To3 = (@shipment.weight * 44 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight3To4 = (@shipment.weight * 36 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight4To5 = (@shipment.weight * 34 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight5To7 = (@shipment.weight * 32 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight7To9 = (@shipment.weight * 31 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight9To11 = (@shipment.weight * 30 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight11Above = (@shipment.chargeable.to_i * 27 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume0To2 = (@shipment.chargeable.to_i * 56 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume2To3 = (@shipment.chargeable.to_i * 44 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume3To4 = (@shipment.chargeable.to_i * 36 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume4To5 = (@shipment.chargeable.to_i * 34 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume5To7 = (@shipment.chargeable.to_i * 32 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume7To9 = (@shipment.chargeable.to_i * 31 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume9To11 = (@shipment.chargeable.to_i * 30 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume11Above = (@shipment.chargeable.to_i * 27 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight0To2ToSS = (@shipment.weight * 72 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight2To3ToSS = (@shipment.weight * 57 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight3To4ToSS = (@shipment.weight * 52 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight4To5ToSS = (@shipment.weight * 50 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight5To6ToSS = (@shipment.weight * 48 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight6To8ToSS = (@shipment.weight * 47 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight8To10ToSS = (@shipment.weight * 46 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight10To11ToSS = (@shipment.weight * 45 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByWeight11AboveToSS = (@shipment.chargeable.to_i * 42 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume0To2ToSS = (@shipment.chargeable.to_i * 72 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume2To3ToSS = (@shipment.chargeable.to_i * 57 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume3To4ToSS = (@shipment.chargeable.to_i * 52 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume4To5ToSS = (@shipment.chargeable.to_i * 50 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume5To6ToSS = (@shipment.chargeable.to_i * 48 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume6To8ToSS = (@shipment.chargeable.to_i * 47 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume8To10ToSS = (@shipment.chargeable.to_i * 46 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume10To11ToSS = (@shipment.chargeable.to_i * 45 + chargePhotoshoot + chargeInspection) * @ringgit
    sensitiveChargeByVolume11AboveToSS = (@shipment.chargeable.to_i * 42 + chargePhotoshoot + chargeInspection) * @ringgit

  if @shipment.repackaging == false && @shipment.reorganize == false
    if @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 3
      @shipment.update(charge: chargeByWeight0To3)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.weight >= 3 && @shipment.weight < 10)
      @shipment.update(charge: chargeByWeight3To10)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 10
      @shipment.update(charge: chargeByWeight10above)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 3
      @shipment.update(charge: chargeByVolume0To3)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: chargeByVolume3To10)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 10
      @shipment.update(charge: chargeByVolume10above)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 11
        @shipment.update(charge: chargeByWeight0To11ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 11
      @shipment.update(charge: chargeByWeight11aboveToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 11
      @shipment.update(charge: chargeByVolume0To11ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: chargeByVolume11aboveToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 7)
      @shipment.update(charge: sensitiveChargeByWeight5To7)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 7 && @shipment.weight < 9)
      @shipment.update(charge: sensitiveChargeByWeight7To9)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 9 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight9To11)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11Above)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 7)
      @shipment.update(charge: sensitiveChargeByVolume5To7)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 7 && @shipment.chargeable.to_i < 9)
      @shipment.update(charge: sensitiveChargeByVolume7To9)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 9 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume9To11)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11Above)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 6)
      @shipment.update(charge: sensitiveChargeByWeight5To6ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 6 && @shipment.weight < 8)
      @shipment.update(charge: sensitiveChargeByWeight6To8ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 8 && @shipment.weight < 10)
      @shipment.update(charge: sensitiveChargeByWeight8To10ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 10 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight10To11ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11AboveToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 6)
      @shipment.update(charge: sensitiveChargeByVolume5To6ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 6 && @shipment.chargeable.to_i < 8)
      @shipment.update(charge: sensitiveChargeByVolume6To8ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 8 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: sensitiveChargeByVolume8To10ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 10 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume10To11ToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11AboveToSS)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    else
      flash[:danger] = "Auto Calculated Fail"
      redirect_to shipments_path
    end

  elsif @shipment.repackaging == true && @shipment.reorganize == false
    if @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 3
      @shipment.update(charge: chargeByWeight0To3 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.weight >= 3 && @shipment.weight < 10)
      @shipment.update(charge: chargeByWeight3To10 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 10
      @shipment.update(charge: chargeByWeight10above + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 3
      @shipment.update(charge: chargeByVolume0To3 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: chargeByVolume3To10 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 10
      @shipment.update(charge: chargeByVolume10above + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 11
        @shipment.update(charge: chargeByWeight0To11ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 11
      @shipment.update(charge: chargeByWeight11aboveToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 11
      @shipment.update(charge: chargeByVolume0To11ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: chargeByVolume11aboveToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 7)
      @shipment.update(charge: sensitiveChargeByWeight5To7 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 7 && @shipment.weight < 9)
      @shipment.update(charge: sensitiveChargeByWeight7To9 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 9 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight9To11 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11Above + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 7)
      @shipment.update(charge: sensitiveChargeByVolume5To7 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 7 && @shipment.chargeable.to_i < 9)
      @shipment.update(charge: sensitiveChargeByVolume7To9 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 9 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume9To11 + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11Above + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 6)
      @shipment.update(charge: sensitiveChargeByWeight5To6ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 6 && @shipment.weight < 8)
      @shipment.update(charge: sensitiveChargeByWeight6To8ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 8 && @shipment.weight < 10)
      @shipment.update(charge: sensitiveChargeByWeight8To10ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 10 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight10To11ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11AboveToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 6)
      @shipment.update(charge: sensitiveChargeByVolume5To6ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 6 && @shipment.chargeable.to_i < 8)
      @shipment.update(charge: sensitiveChargeByVolume6To8ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 8 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: sensitiveChargeByVolume8To10ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 10 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume10To11ToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11AboveToSS + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    else
      flash[:danger] = "Auto Calculated Fail"
      redirect_to shipments_path
    end

  elsif @shipment.repackaging == false && @shipment.reorganize == true
    if @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 3
      @shipment.update(charge: chargeByWeight0To3 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.weight >= 3 && @shipment.weight < 10)
      @shipment.update(charge: chargeByWeight3To10 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 10
      @shipment.update(charge: chargeByWeight10above + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 3
      @shipment.update(charge: chargeByVolume0To3 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: chargeByVolume3To10 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 10
      @shipment.update(charge: chargeByVolume10above + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 11
        @shipment.update(charge: chargeByWeight0To11ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 11
      @shipment.update(charge: chargeByWeight11aboveToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 11
      @shipment.update(charge: chargeByVolume0To11ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: chargeByVolume11aboveToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 7)
      @shipment.update(charge: sensitiveChargeByWeight5To7 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 7 && @shipment.weight < 9)
      @shipment.update(charge: sensitiveChargeByWeight7To9 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 9 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight9To11 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11Above + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 7)
      @shipment.update(charge: sensitiveChargeByVolume5To7 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 7 && @shipment.chargeable.to_i < 9)
      @shipment.update(charge: sensitiveChargeByVolume7To9 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 9 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume9To11 + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11Above + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 6)
      @shipment.update(charge: sensitiveChargeByWeight5To6ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 6 && @shipment.weight < 8)
      @shipment.update(charge: sensitiveChargeByWeight6To8ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 8 && @shipment.weight < 10)
      @shipment.update(charge: sensitiveChargeByWeight8To10ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 10 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight10To11ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11AboveToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 6)
      @shipment.update(charge: sensitiveChargeByVolume5To6ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 6 && @shipment.chargeable.to_i < 8)
      @shipment.update(charge: sensitiveChargeByVolume6To8ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 8 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: sensitiveChargeByVolume8To10ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 10 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume10To11ToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11AboveToSS + chargeReorganize)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    else
      flash[:danger] = "Auto Calculated Fail"
      redirect_to shipments_path
    end
  else
    if @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 3
      @shipment.update(charge: chargeByWeight0To3 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.weight >= 3 && @shipment.weight < 10)
      @shipment.update(charge: chargeByWeight3To10 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 10
      @shipment.update(charge: chargeByWeight10above + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 3
      @shipment.update(charge: chargeByVolume0To3 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: chargeByVolume3To10 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 10
      @shipment.update(charge: chargeByVolume10above + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight < 11
        @shipment.update(charge: chargeByWeight0To11ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.weight >= 11
      @shipment.update(charge: chargeByWeight11aboveToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i < 11
      @shipment.update(charge: chargeByVolume0To11ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: chargeByVolume11aboveToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 7)
      @shipment.update(charge: sensitiveChargeByWeight5To7 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 7 && @shipment.weight < 9)
      @shipment.update(charge: sensitiveChargeByWeight7To9 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 9 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight9To11 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11Above + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 7)
      @shipment.update(charge: sensitiveChargeByVolume5To7 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 7 && @shipment.chargeable.to_i < 9)
      @shipment.update(charge: sensitiveChargeByVolume7To9 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 9 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume9To11 + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11Above + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 2 && @shipment.weight < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 3 && @shipment.weight < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 4 && @shipment.weight < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 5 && @shipment.weight < 6)
      @shipment.update(charge: sensitiveChargeByWeight5To6ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 6 && @shipment.weight < 8)
      @shipment.update(charge: sensitiveChargeByWeight6To8ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 8 && @shipment.weight < 10)
      @shipment.update(charge: sensitiveChargeByWeight8To10ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.weight >= 10 && @shipment.weight < 11)
      @shipment.update(charge: sensitiveChargeByWeight10To11ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight > @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.weight >= 11
      @shipment.update(charge: sensitiveChargeByWeight11AboveToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i < 2
        @shipment.update(charge: sensitiveChargeByVolume0To2ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 2 && @shipment.chargeable.to_i < 3)
      @shipment.update(charge: sensitiveChargeByVolume2To3ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 3 && @shipment.chargeable.to_i < 4)
      @shipment.update(charge: sensitiveChargeByVolume3To4ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 4 && @shipment.chargeable.to_i < 5)
      @shipment.update(charge: sensitiveChargeByVolume4To5ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 5 && @shipment.chargeable.to_i < 6)
      @shipment.update(charge: sensitiveChargeByVolume5To6ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 6 && @shipment.chargeable.to_i < 8)
      @shipment.update(charge: sensitiveChargeByVolume6To8ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 8 && @shipment.chargeable.to_i < 10)
      @shipment.update(charge: sensitiveChargeByVolume8To10ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.chargeable.to_i >= 10 && @shipment.chargeable.to_i < 11)
      @shipment.update(charge: sensitiveChargeByVolume10To11ToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.weight <= @shipment.chargeable.to_i && @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.chargeable.to_i >= 11
      @shipment.update(charge: sensitiveChargeByVolume11AboveToSS + chargeReorganize + chargeRepackaging)
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    else
      flash[:danger] = "Auto Calculated Fail"
      redirect_to shipments_path
    end
  end

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
      @shipments= Shipment.all.where(status: 'Paid').order(updated_at: :desc).page params[:page]
      else
      @shipments= current_user.shipments.where(status: 'Paid').order(updated_at: :desc).page params[:page]
      end

    end

  private

    def shipment_params
      params.require(:shipment).permit(:status, :remark, :weight, :volume, :charge, :bill_id, :bill_url, :due_at, :paid_at, :reorganize, :repackaging)
    end

    def calculate_params
      params.require(:shipment).permit(:charge)
    end


end
