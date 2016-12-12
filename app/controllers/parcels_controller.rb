class ParcelsController < ApplicationController
  before_action :authenticate!

  def index

    if admin_user || staff_user
    @parcels= Parcel.all.order(updated_at: :desc).page params[:page]
    else
    @parcels= current_user.parcels.order(updated_at: :desc).page params[:page]
    end

    if params[:search]
      if admin_user || staff_user
      @parcels = Parcel.search(params[:search]).order("updated_at DESC").page params[:page]
      else
      @parcels = current_user.parcels.search(params[:search]).order("updated_at DESC").page params[:page]
    end
    else
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
      @parcel.update_attributes(status: :Pending)
      @parcel.create_activity :create, owner: current_user
      flash[:success] = "You've created a parcel."
      redirect_to parcels_path
    else
      flash[:danger]
      redirect_to new_parcel_path
    end
  end

  def edit
    @parcel = Parcel.find(params[:id])
    authorize @parcel

  end

  def update
      @parcel = Parcel.find(params[:id])
      authorize @parcel

      if @parcel.update(parcel_params)
        if @parcel.weight && @parcel.volume != nil
          @parcel.update_attributes(status: :Arrived)
          @parcel.create_activity :update, owner: current_user
        else
        end
        flash[:success] = "You've updated your parcel!"
        redirect_to parcel_path(@parcel)
      else
        redirect_to parcels_path
        flash[:danger]
      end
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

  private

    def parcel_params
      params.require(:parcel).permit(:awb, :description, :image, :remark, :parcel_good, :status, :volume, :weight, :photoshoot, :inspection, :product_chinese, :product_quantity, :product_total_price, :price_per_unit)
    end

end
