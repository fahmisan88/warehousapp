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

    extraCharge = @shipment.extra_charge
    chargeReorganize = @shipment.parcels.size * 2 * @ringgit
    chargeRepackaging = @shipment.parcels.size * 10 * @ringgit
    chargePhotoshoot = @shipment.parcels.where(photoshoot: true).size * 10
    chargeInspection = @shipment.parcels.where(inspection: true).size * 30

    chargeByWeight0To3 = (@shipment.final_kg * 30 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    chargeByWeight3To10 = (@shipment.final_kg * 26 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    chargeByWeight10above = (@shipment.final_kg * 23 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    chargeByWeight0To11ToSS = (@shipment.final_kg * 41 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    chargeByWeight11aboveToSS = (@shipment.final_kg * 38 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight0To2 = (@shipment.final_kg * 56 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight2To3 = (@shipment.final_kg * 44 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight3To4 = (@shipment.final_kg * 36 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight4To5 = (@shipment.final_kg * 34 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight5To7 = (@shipment.final_kg * 32 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight7To9 = (@shipment.final_kg * 31 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight9To11 = (@shipment.final_kg * 30 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight11Above = (@shipment.final_kg * 27 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight0To2ToSS = (@shipment.final_kg * 72 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight2To3ToSS = (@shipment.final_kg * 57 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight3To4ToSS = (@shipment.final_kg * 52 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight4To5ToSS = (@shipment.final_kg * 50 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight5To6ToSS = (@shipment.final_kg * 48 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight6To8ToSS = (@shipment.final_kg * 47 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight8To10ToSS = (@shipment.final_kg * 46 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight10To11ToSS = (@shipment.final_kg * 45 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit
    sensitiveChargeByWeight11AboveToSS = (@shipment.final_kg * 42 + chargePhotoshoot + chargeInspection + extraCharge ) * @ringgit

    if @shipment.repackaging == false && @shipment.reorganize == false
      if @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 3
        @shipment.update(charge: chargeByWeight0To3)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.final_kg >= 3 && @shipment.final_kg < 10)
        @shipment.update(charge: chargeByWeight3To10)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 10
        @shipment.update(charge: chargeByWeight10above)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 11
        @shipment.update(charge: chargeByWeight0To11ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 11
        @shipment.update(charge: chargeByWeight11aboveToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 7)
        @shipment.update(charge: sensitiveChargeByWeight5To7)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 7 && @shipment.final_kg < 9)
        @shipment.update(charge: sensitiveChargeByWeight7To9)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 9 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight9To11)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11Above)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 6)
        @shipment.update(charge: sensitiveChargeByWeight5To6ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 6 && @shipment.final_kg < 8)
        @shipment.update(charge: sensitiveChargeByWeight6To8ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 8 && @shipment.final_kg < 10)
        @shipment.update(charge: sensitiveChargeByWeight8To10ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 10 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight10To11ToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11AboveToSS)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      else
        flash[:danger] = "Auto Calculated Fail"
        redirect_to shipments_path
      end

    elsif @shipment.repackaging == true && @shipment.reorganize == false
      if @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 3
        @shipment.update(charge: chargeByWeight0To3 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.final_kg >= 3 && @shipment.final_kg < 10)
        @shipment.update(charge: chargeByWeight3To10 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 10
        @shipment.update(charge: chargeByWeight10above + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 11
        @shipment.update(charge: chargeByWeight0To11ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 11
        @shipment.update(charge: chargeByWeight11aboveToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 7)
        @shipment.update(charge: sensitiveChargeByWeight5To7 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 7 && @shipment.final_kg < 9)
        @shipment.update(charge: sensitiveChargeByWeight7To9 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 9 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight9To11 + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11Above + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 6)
        @shipment.update(charge: sensitiveChargeByWeight5To6ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 6 && @shipment.final_kg < 8)
        @shipment.update(charge: sensitiveChargeByWeight6To8ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 8 && @shipment.final_kg < 10)
        @shipment.update(charge: sensitiveChargeByWeight8To10ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 10 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight10To11ToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11AboveToSS + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      else
        flash[:danger] = "Auto Calculated Fail"
        redirect_to shipments_path
      end

    elsif @shipment.repackaging == false && @shipment.reorganize == true
      if @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 3
        @shipment.update(charge: chargeByWeight0To3 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.final_kg >= 3 && @shipment.final_kg < 10)
        @shipment.update(charge: chargeByWeight3To10 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 10
        @shipment.update(charge: chargeByWeight10above + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 11
        @shipment.update(charge: chargeByWeight0To11ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 11
        @shipment.update(charge: chargeByWeight11aboveToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 7)
        @shipment.update(charge: sensitiveChargeByWeight5To7 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 7 && @shipment.final_kg < 9)
        @shipment.update(charge: sensitiveChargeByWeight7To9 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 9 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight9To11 + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11Above + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 6)
        @shipment.update(charge: sensitiveChargeByWeight5To6ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 6 && @shipment.final_kg < 8)
        @shipment.update(charge: sensitiveChargeByWeight6To8ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 8 && @shipment.final_kg < 10)
        @shipment.update(charge: sensitiveChargeByWeight8To10ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 10 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight10To11ToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11AboveToSS + chargeReorganize)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      else
        flash[:danger] = "Auto Calculated Fail"
        redirect_to shipments_path
      end

      else

      if @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 3
        @shipment.update(charge: chargeByWeight0To3 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.final_kg >= 3 && @shipment.final_kg < 10)
        @shipment.update(charge: chargeByWeight3To10 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 10
        @shipment.update(charge: chargeByWeight10above + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 11
        @shipment.update(charge: chargeByWeight0To11ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 11
        @shipment.update(charge: chargeByWeight11aboveToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 7)
        @shipment.update(charge: sensitiveChargeByWeight5To7 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 7 && @shipment.final_kg < 9)
        @shipment.update(charge: sensitiveChargeByWeight7To9 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 9 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight9To11 + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11Above + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
        @shipment.update(charge: sensitiveChargeByWeight0To2ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
        @shipment.update(charge: sensitiveChargeByWeight2To3ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
        @shipment.update(charge: sensitiveChargeByWeight3To4ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
        @shipment.update(charge: sensitiveChargeByWeight4To5ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 6)
        @shipment.update(charge: sensitiveChargeByWeight5To6ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 6 && @shipment.final_kg < 8)
        @shipment.update(charge: sensitiveChargeByWeight6To8ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 8 && @shipment.final_kg < 10)
        @shipment.update(charge: sensitiveChargeByWeight8To10ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 10 && @shipment.final_kg < 11)
        @shipment.update(charge: sensitiveChargeByWeight10To11ToSS + chargeReorganize + chargeRepackaging)
        flash[:success] ="Auto Calculated!"
        redirect_to edit_shipment_path(@shipment)
      elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
        @shipment.update(charge: sensitiveChargeByWeight11AboveToSS + chargeReorganize + chargeRepackaging)
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

  def add_charge
    @shipment = Shipment.find(params[:id])
    if @shipment.update(add_charge_params)
      flash[:success] ="Successfully added extra charge!"
    else
      flash[:danger] = "Failed to add charge"
    end
    redirect_to edit_shipment_path(@shipment)
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
    params.require(:shipment).permit(:status, :remark, :charge, :bill_id, :bill_url, :due_at, :paid_at, :reorganize, :repackaging, :sea_freight)
  end

  def calculate_params
    params.require(:shipment).permit(:charge)
  end

  def add_charge_params
    params.require(:shipment).permit(:repackaging, :reorganize, :extra_charge, :extra_remark)
  end


end
