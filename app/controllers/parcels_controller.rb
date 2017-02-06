class ParcelsController < ApplicationController
  before_action :authenticate!

  def index

    if admin_user || staff_user
    @parcels= Parcel.all.order(updated_at: :desc).page params[:page]
    else
    @parcels= current_user.parcels.order(updated_at: :desc).page params[:page]
    end

    if params[:search0]
      if admin_user || staff_user
        @parcels = Parcel.search0(params[:search0]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search0(params[:search0]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search1]
      if admin_user || staff_user
        @parcels = Parcel.search1(params[:search1]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search1(params[:search1]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search2]
      if admin_user || staff_user
        @parcels = Parcel.search2(params[:search2]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search2(params[:search2]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search3]
      if admin_user || staff_user
        @parcels = Parcel.search3(params[:search3]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search3(params[:search3]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search4]
      if admin_user || staff_user
        @parcels = Parcel.search4(params[:search4]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search4(params[:search4]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search5]
      if admin_user || staff_user
        @parcels = Parcel.search5(params[:search5]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search5(params[:search5]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search6]
      if admin_user || staff_user
        @parcels = Parcel.search6(params[:search6]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search6(params[:search6]).order("updated_at DESC").page params[:page]
      end
    elsif params[:search]
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

  def show_image
    @parcel = Parcel.find_by(id: params[:id])
    # authorize @parcel
  end

  def new
    @parcel= Parcel.new
  end

  def create
      @parcel= current_user.parcels.build(parcel_params)
      authorize @parcel
    if @parcel.save
      @parcel.update_attributes(status: 0)
      flash[:success] = "Thank you for your time. You've successfully created a parcel."
      deliver_mail(current_user.name, current_user.email, "parcels", "created")
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

  def edit_awb
    @parcel = Parcel.find(params[:id])
    authorize @parcel
  end

  def update
      @parcel = Parcel.find(params[:id])
      authorize @parcel

      if @parcel.update(update_parcel_params)
        if @parcel.weight? && @parcel.length? && @parcel.width? && @parcel.height?
        @parcel.update_attributes(volume: ((@parcel.length * @parcel.width * @parcel.height)/6000.to_f).ceil, weight: (@parcel.weight.to_f).ceil)
        @parcel.update_attributes(chargeable: ((@parcel.weight+@parcel.volume)/2.to_f).ceil)
        if @parcel.weight >= @parcel.chargeable
          @parcel.update_attributes(final_kg: @parcel.weight, status: 1, free_storage: Time.now + 15.days)
        else
          @parcel.update_attributes(final_kg: @parcel.chargeable, status: 1, free_storage: Time.now + 15.days)
        end
          @parcel_user = @parcel.user_id
          @user_info = User.find(@parcel_user)
          deliver_mail(@user_info.name, @user_info.email, "parcels", "arrived")
        else
        end
        flash[:success] = "You've successfully updated the parcel!"
        redirect_to parcel_path(@parcel)
      else
        redirect_to parcels_path
        flash[:danger] = "Update parcel fail"
      end
    end

    def update_awb
        @parcel = Parcel.find(params[:id])
        authorize @parcel

        if @parcel.update(update_awb_params)
          if @parcel.refund == true
            @parcel.update_attributes(status: 4)
            flash[:success] = "You've successfully request a refund!"
          elsif @parcel.refund == false
            flash[:danger] = "Request refund fail"
          elsif @parcel.new_awb?
            flash[:success] = "You've successfully change your AWB number!"
          else
          end
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
      params.require(:parcel).permit(:awb, :description, :image, :remark, :parcel_good, :photoshoot, :inspection, :product_chinese, :product_quantity, :product_total_price, :price_per_unit)
    end

    def update_parcel_params
      params.require(:parcel).permit(:image5,:image4, :image3, :image2,:image1,:length,:width,:height,:volume,:weight,:chargeable, :status, :free_storage)
    end

    def update_awb_params
      params.require(:parcel).permit(:new_awb,:refund,:refund_explain)
    end

end
