class ParcelsController < ApplicationController
  before_action :authenticate!

  def index
    @filter_params = params[:status]
    @parcels= current_user.parcels.order(updated_at: :desc).page params[:page]

		if @filter_params == "Waiting"
      @parcels = current_user.parcels.where(status: 0).order("created_at desc").page(params[:page])
    elsif @filter_params == "Arrived"
      @parcels = current_user.parcels.where(status: 1).order("created_at desc").page(params[:page])
		elsif @filter_params == "Ready To Ship"
      @parcels = current_user.parcels.where(status: 2).order("created_at desc").page(params[:page])
		elsif @filter_params == "Shipped"
      @parcels = current_user.parcels.where(status: 3).order("created_at desc").page(params[:page])
    elsif @filter_params == "Request Refund"
      @parcels = current_user.parcels.where(status: 4).order("created_at desc").page(params[:page])
    elsif @filter_params == "Refund Rejected"
      @parcels = current_user.parcels.where(status: 5).order("created_at desc").page(params[:page])
		elsif @filter_params == "Refunded"
      @parcels = current_user.parcels.where(status: 6).order("created_at desc").page(params[:page])
		end

    if params[:search]
      @parcels = current_user.parcels.search(params[:search]).order("updated_at DESC").page params[:page]
    end

  end

  def show
    @parcel = Parcel.find_by(id: params[:id])
    authorize @parcel
  end

  def new
    @parcel= Parcel.new
  end

  def create
    @parcel= current_user.parcels.build(parcel_params)
    authorize @parcel
    if @parcel.save
      flash[:success] = "Thank you for your time. You've successfully created a parcel."
      # deliver_mail(current_user.name, current_user.email, "parcels", "created")
      redirect_to parcels_path
    else
      flash[:danger] = "Something went wrong. Please try again."
      render new_parcel_path
    end
  end

  def edit
    @parcel = Parcel.find(params[:id])
    authorize @parcel
  end

  def request_refund
    @parcel = Parcel.find(params[:id])
    authorize @parcel
    if @parcel.status != "Arrived"
      redirect_to parcel_path(@parcel)
    end
  end

  def update_request_refund
    @parcel = Parcel.find(params[:id])
    authorize @parcel
    if @parcel.update(request_refund_params)
      @parcel.update_attributes(status: 4)
      flash[:success] = "You've successfully request a refund!"
    else
      flash[:danger] = "Request refund fail"
    end
    redirect_to parcel_path(@parcel)
  end

  def destroy
    @parcel = Parcel.find(params[:id])
    authorize @parcel

    if @parcel.destroy
      redirect_to parcels_path
      flash[:success] = "You've deleted a parcel."
    else
      flash[:danger]
      redirect_to parcels_path
    end
  end

  # check the existence of ezi_id. 'ezicode_exist' is a helper method than con found at controller superclass (application_controller.rb). use for form validation.
  def checkezicode
    ezicode_exist
  end

  private

  def parcel_params
    params.require(:parcel).permit(:awb, :description, :image, :remark, :parcel_good, :photoshoot, :inspection, :product_chinese, :product_quantity, :product_total_price, :price_per_unit, :ezi_id)
  end

  def request_refund_params
    params.require(:parcel).permit(:refund,:refund_explain)
  end

end
