class ShipmentsController < ApplicationController
  before_action :authenticate!


  def index
    if admin_user || staff_user
      @shipments= Shipment.all.order(updated_at: :desc).page params[:page]
    else
      @shipments= current_user.shipments.order(updated_at: :desc).page params[:page]
    end

    if params[:search0]
      if admin_user || staff_user
        @shipments = Shipment.search0(params[:search0]).order("updated_at DESC").page params[:page]
      else
        @shipments = current_user.shipments.search0(params[:search0]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search1]
      if admin_user || staff_user
        @shipments = Shipment.search1(params[:search1]).order("updated_at DESC").page params[:page]
      else
        @shipments = current_user.shipments.search1(params[:search1]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search2]
      if admin_user || staff_user
        @shipments = Shipment.search2(params[:search2]).order("updated_at DESC").page params[:page]
      else
        @shipments = current_user.shipments.search2(params[:search2]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search]
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
      # deliver_mail(current_user.name, current_user.email, "shipments", "created")
      redirect_to shipments_path
    else
      flash[:danger]
      redirect_to new_shipment_path
    end
  end

  def edit
    @shipment = Shipment.find(params[:id])
    @parcels = current_user.parcels.where(status: 2)
    authorize @shipment
  end

  def calculate
    @shipment = Shipment.find(params[:id])
    @currency = Currency.find_by(id: 1)
    @ringgit = @currency.myr2rmb

    extraCharge = @shipment.extra_charge
    minusCharge = @shipment.minus_charge
    chargePhotoshoot = @shipment.parcels.where(photoshoot: true).size * 10
    chargeInspection = @shipment.parcels.where(inspection: true).size * 30
    if @shipment.reorganize?
    chargeReorganize = @shipment.parcels.size * 2
    else
    chargeReorganize = 0
    end
    if @shipment.repackaging?
    chargeRepackaging = 10
    else
    chargeRepackaging = 0
    end

    chargeByWeight0To3 = (@shipment.final_kg * 30 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    chargeByWeight3To10 = (@shipment.final_kg * 26 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    chargeByWeight10above = (@shipment.final_kg * 23 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    chargeByWeight0To11ToSS = (@shipment.final_kg * 41 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    chargeByWeight11aboveToSS = (@shipment.final_kg * 38 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight0To2 = (@shipment.final_kg * 56 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight2To3 = (@shipment.final_kg * 44 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight3To4 = (@shipment.final_kg * 36 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight4To5 = (@shipment.final_kg * 34 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight5To7 = (@shipment.final_kg * 32 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight7To9 = (@shipment.final_kg * 31 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight9To11 = (@shipment.final_kg * 30 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight11Above = (@shipment.final_kg * 27 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight0To2ToSS = (@shipment.final_kg * 72 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight2To3ToSS = (@shipment.final_kg * 57 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight3To4ToSS = (@shipment.final_kg * 52 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight4To5ToSS = (@shipment.final_kg * 50 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight5To6ToSS = (@shipment.final_kg * 48 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight6To8ToSS = (@shipment.final_kg * 47 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight8To10ToSS = (@shipment.final_kg * 46 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight10To11ToSS = (@shipment.final_kg * 45 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit
    sensitiveChargeByWeight11AboveToSS = (@shipment.final_kg * 42 + chargeRepackaging + chargeReorganize + chargePhotoshoot + chargeInspection + extraCharge - minusCharge ) / @ringgit


    if @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 3
      @shipment.update(charge: chargeByWeight0To3.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && (@shipment.final_kg >= 3 && @shipment.final_kg < 10)
      @shipment.update(charge: chargeByWeight3To10.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 10
      @shipment.update(charge: chargeByWeight10above.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg < 11
      @shipment.update(charge: chargeByWeight0To11ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Normal" && @shipment.final_kg >= 11
      @shipment.update(charge: chargeByWeight11aboveToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
      @shipment.update(charge: sensitiveChargeByWeight0To2.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 7)
      @shipment.update(charge: sensitiveChargeByWeight5To7.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 7 && @shipment.final_kg < 9)
      @shipment.update(charge: sensitiveChargeByWeight7To9.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 9 && @shipment.final_kg < 11)
      @shipment.update(charge: sensitiveChargeByWeight9To11.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 != ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
      @shipment.update(charge: sensitiveChargeByWeight11Above.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg < 2
      @shipment.update(charge: sensitiveChargeByWeight0To2ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 2 && @shipment.final_kg < 3)
      @shipment.update(charge: sensitiveChargeByWeight2To3ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 3 && @shipment.final_kg < 4)
      @shipment.update(charge: sensitiveChargeByWeight3To4ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 4 && @shipment.final_kg < 5)
      @shipment.update(charge: sensitiveChargeByWeight4To5ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 5 && @shipment.final_kg < 6)
      @shipment.update(charge: sensitiveChargeByWeight5To6ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 6 && @shipment.final_kg < 8)
      @shipment.update(charge: sensitiveChargeByWeight6To8ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 8 && @shipment.final_kg < 10)
      @shipment.update(charge: sensitiveChargeByWeight8To10ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && (@shipment.final_kg >= 10 && @shipment.final_kg < 11)
      @shipment.update(charge: sensitiveChargeByWeight10To11ToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    elsif @shipment.user.address2 == ("Sabah" || "Sarawak") && @shipment.shipment_type == "Sensitive" && @shipment.final_kg >= 11
      @shipment.update(charge: sensitiveChargeByWeight11AboveToSS.ceil(1))
      flash[:success] ="Auto Calculated!"
      redirect_to edit_shipment_path(@shipment)
    else
      flash[:danger] = "Auto Calculated Fail"
      redirect_to shipments_path
    end
  end

  def sea_calculate
    @shipment = Shipment.find(params[:id])
    @currency = Currency.find_by(id: 1)
    @ringgit = @currency.myr2rmb

    extraCharge = @shipment.extra_charge / @ringgit
    minusCharge = @shipment.minus_charge / @ringgit
    if @shipment.sea_freight?
      @shipment.update(sea_calculate_params)
      chargeMYR = @shipment.sea_charge + extraCharge - minusCharge
      @shipment.update_attributes(charge: chargeMYR.ceil(1))
      flash[:success] ="Sea Freight Charge calculated successfully"
    else
      flash[:danger] = "Sea Freight Calculation Fail"
    end
    redirect_to edit_shipment_path(@shipment)
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
      @shipments= Shipment.all.where(status: 2).order(updated_at: :desc).page params[:page]
    else
      @shipments= current_user.shipments.where(status: 2).order(updated_at: :desc).page params[:page]
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
    params.require(:shipment).permit(:repackaging, :reorganize, :extra_charge, :extra_remark, :minus_charge)
  end

  def sea_calculate_params
    params.require(:shipment).permit(:sea_charge)
  end


end
