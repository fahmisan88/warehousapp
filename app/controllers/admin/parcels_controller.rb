class Admin::ParcelsController < ApplicationController
  before_filter :check_if_admin

  def index
    @filter_params = params[:status]
    @parcels       = Parcel.all.order(updated_at: :desc).page(params[:page]).per(15)

    case @filter_params
    when "Waiting"
      @parcels = Parcel.where(status: 0).order("created_at desc").page(params[:page]).per(15)
    when "Arrived"
      @parcels = Parcel.where(status: 1).order("created_at desc").page(params[:page]).per(15)
    when "Ready To Ship"
      @parcels = Parcel.where(status: 2).order("created_at desc").page(params[:page]).per(15)
    when "Shipped"
      @parcels = Parcel.where(status: 3).order("created_at desc").page(params[:page]).per(15)
    when "Request Refund"
      @parcels = Parcel.where(status: 4).order("created_at desc").page(params[:page]).per(15)
    when "Refund Rejected"
      @parcels = Parcel.where(status: 5).order("created_at desc").page(params[:page]).per(15)
    when "Refunded"
      @parcels = Parcel.where(status: 6).order("created_at desc").page(params[:page]).per(15)
    when "Normal"
      @parcels = Parcel.where(parcel_good: 0).order("created_at desc").page(params[:page]).per(15)
    when "Sensitive"
      @parcels = Parcel.where(parcel_good: 1).order("created_at desc").page(params[:page]).per(15)
    when "I Dont Know"
      @parcels = Parcel.where(parcel_good: 2).order("created_at desc").page(params[:page]).per(15)
    end

    if params[:search]
      @parcels = Parcel.search(params[:search]).order("updated_at DESC").page(params[:page]).per(15)
    end
    if params[:search_ezi]
      @parcels = Parcel.search_ezi(params[:search_ezi]).order("updated_at DESC").page(params[:page]).per(15)
    end
  end

  def show
    @parcel = Parcel.find_by(id: params[:id])
  end

  def new
    @parcel = Parcel.new
  end

  def create
    @parcel      = current_user.parcels.build(parcel_params)
    @user        = User.find_by(ezi_id: @parcel.ezi_id)
    volume       = ((@parcel.length * @parcel.width * @parcel.height)/6000.to_f).ceil
    weight       = (@parcel.weight.to_f).ceil
    chargeable   = ((weight + volume)/2.to_f).ceil
    free_storage = Time.now + 15.days

    if weight >= chargeable
      final_kg = weight
    else
      final_kg = chargeable
    end

    if @user.present?
      if @parcel.save
        @parcel.update(user_id: @user.id, status: 1, volume: volume, weight: weight, chargeable: chargeable, free_storage: free_storage, final_kg: final_kg)
        @parcel_user    = @parcel.user_id
        deliver_mail(@user.name, @user.email, "parcels", "arrived")
        flash[:success] = "You have created a parcel for user #{@parcel.ezi_id}"
        redirect_to admin_parcels_path
      else
        flash[:danger] = @parcel.errors.full_messages
        render new_admin_parcel_path
      end
    else
      flash[:danger] = "User not found. Please enter the Ezi ID correctly."
      render new_admin_parcel_path
    end
  end

  def edit
    @parcel = Parcel.find(params[:id])
  end

  def update
    @parcel = Parcel.find(params[:id])
    if @parcel.update(update_parcel_params)
      volume       = ((@parcel.length * @parcel.width * @parcel.height)/6000.to_f).ceil
      weight       = (@parcel.weight.to_f).ceil
      chargeable   = ((weight + volume)/2.to_f).ceil
      free_storage = Time.now + 15.days

      if weight >= chargeable
        final_kg = weight
      else
        final_kg = chargeable
      end

      @parcel.update(volume: volume, weight: weight, chargeable: chargeable, free_storage: free_storage, final_kg: final_kg, status: "Arrived")
      @parcel_user = @parcel.user_id
      @user_info   = User.find(@parcel_user)
      # deliver_mail(@user_info.name, @user_info.email, "parcels", "arrived")
      flash[:success] = "You've successfully updated the parcel!"
      redirect_to admin_parcel_path(@parcel)
    else
      flash[:danger] = @parcel.errors.full_messages
      render :edit
    end
  end

  def destroy
    @parcel = Parcel.find(params[:id])
    if @parcel.destroy
      redirect_to parcels_path
      flash[:success] = "You've deleted a parcel."
    else
      flash[:danger]
      redirect_to parcels_path
    end
  end

  def accept_refund
    @parcel = Parcel.find(params[:id])
    @parcel.update(status: "Refunded")
    redirect_to admin_parcel_path(@parcel)
  end

  def reject_refund
    @parcel = Parcel.find(params[:id])
    @parcel.update(status: "Refund Rejected")
    redirect_to admin_parcel_path(@parcel)
  end

  private

  def parcel_params
    params.require(:parcel).permit(:awb, :description, :image, :remark, :parcel_good, :photoshoot, :inspection, :product_chinese, :product_quantity, :product_total_price, :price_per_unit, :ezi_id,:length,:width,:height,:weight,:volume)
  end

  def update_parcel_params
    params.require(:parcel).permit(:length, :width, :height, :volume, :weight, :chargeable, :status, :free_storage, :parcel_good, :remark_admin, { images: [] })
  end

end
