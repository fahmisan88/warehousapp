class ParcelsController < ApplicationController
  before_action :authenticate!

  def index
    @filter_params = params[:status]

    if admin_user || staff_user
    @parcels= Parcel.all.order(updated_at: :desc).page params[:page]
    else
    @parcels= current_user.parcels.order(updated_at: :desc).page params[:page]
    end

		if @filter_params == "Waiting"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 0).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 0).order("created_at desc").page(params[:page])
      end
    elsif @filter_params == "Arrived"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 1).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 1).order("created_at desc").page(params[:page])
      end
		elsif @filter_params == "Ready To Ship"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 2).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 2).order("created_at desc").page(params[:page])
      end
		elsif @filter_params == "Shipped"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 3).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 3).order("created_at desc").page(params[:page])
      end
    elsif @filter_params == "Request"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 4).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 4).order("created_at desc").page(params[:page])
      end
    elsif @filter_params == "Refunding"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 5).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 5).order("created_at desc").page(params[:page])
      end
		elsif @filter_params == "Refunded"
      if admin_user || staff_user
        @parcels = Parcel.where(status: 6).order("created_at desc").page(params[:page])
      else
        @parcels = current_user.parcels.where(status: 6).order("created_at desc").page(params[:page])
      end
		end

    if params[:search]
      if admin_user || staff_user
        @parcels = Parcel.search(params[:search]).order("updated_at DESC").page params[:page]
      else
        @parcels = current_user.parcels.search(params[:search]).order("updated_at DESC").page params[:page]
      end
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
      @parcel.update_attributes(status: 0, weight: 0.5, width: 1, length: 1, height: 1)
      flash[:success] = "Thank you for your time. You've successfully created a parcel."
      # deliver_mail(current_user.name, current_user.email, "parcels", "created")
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
    if @parcel.status != "Waiting"
      redirect_to parcel_path(@parcel)
    end
  end

  def request_refund
    @parcel = Parcel.find(params[:id])
    authorize @parcel
    if @parcel.status != "Arrived"
      redirect_to parcel_path(@parcel)
    end
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
          flash[:success] = "You've successfully change your AWB number!"
        else
          flash[:danger] = "Failed to update AWB number"
        end
          redirect_to parcel_path(@parcel)
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

      def update_refund
        @parcel = Parcel.find(params[:id])
        if @parcel.update(update_refund_params)
          flash[:success] = "You 've updated the request status of this parcel"
        else
          flash[:danger] = "Fail to update"
        end
        redirect_to parcels_path
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

    def admin_create_parcel_show
      authorize current_user
      @parcel = Parcel.new
    end

    # use only for admin to create new parcels for users due sometime seller deliver extra parcels without user acknowledges.
    def admin_create
      @parcel= current_user.parcels.build(parcel_params)
      authorize @parcel
      if @parcel.save
        @parcel.update_attributes(status: 0, weight: 0.5, width: 1, length: 1, height: 1)
        flash[:success] = "Thank you for your time. You've successfully created a parcel."
        # deliver_mail(current_user.name, current_user.email, "parcels", "created")
        redirect_to parcels_path
      else
        flash[:danger]
        redirect_to new_parcel_path
      end
    end

    def user_exist
      @user = User.find_by(ezi_id: parcel_params[:ezi_id].upcase)
      if @user.present?
        respond_to do |format|
          format.json {render json: { valid: true }}
        end
      else
        respond_to do |format|
          format.json {render json: { valid: false, message: "Ezicargo Code not exists" }}
        end
      end
    end

  private

    def parcel_params
      params.require(:parcel).permit(:awb, :description, :image, :remark, :parcel_good, :photoshoot, :inspection, :product_chinese, :product_quantity, :product_total_price, :price_per_unit, :ezi_id)
    end

    def update_parcel_params
      params.require(:parcel).permit(:image5,:image4, :image3, :image2,:image1,:length,:width,:height,:volume,:weight,:chargeable, :status, :free_storage, :remark_admin)
    end

    def update_awb_params
      params.require(:parcel).permit(:new_awb)
    end

    def request_refund_params
      params.require(:parcel).permit(:refund,:refund_explain)
    end

    def update_refund_params
      params.require(:parcel).permit(:status)
    end

end
