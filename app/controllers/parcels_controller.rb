class ParcelsController < ApplicationController
  before_action :authenticate!

  include Sendinblue

  def testmail
    mailer = Mailin.new(ENV['SENDINBLUE_API_URL'], ENV['SENDINBLUE_API_KEY'], 10)
    data = {"id" => 15, "to" => "nor.azlan.idris@gmail.com", "attr" => {"NAME" => "Smith John"}, "headers" => {"Content-Type" => "text/html;charset=iso-8859-1"} }
    result = mailer.send_transactional_template(data)
    puts result['code'] == "success" ? "email sent" : "opss..error"
  end

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

      @user_id = @parcel.user_id
      @user = User.find(@user_id)



      if @parcel.update(update_parcel_params)
        if @parcel.weight? && @parcel.length? && @parcel.width? && @parcel.height?
          @parcel.update_attributes(volume: ((@parcel.length * @parcel.width * @parcel.height)/6000.to_f).ceil, weight: (@parcel.weight.to_f).ceil)
          @parcel.update_attributes(chargeable: ((@parcel.weight+@parcel.volume)/2.to_f).ceil)
          if @parcel.weight >= @parcel.chargeable
            @parcel.update_attributes(final_kg: @parcel.weight, status: 1, free_storage: Time.now + 15.days)
          else
            @parcel.update_attributes(final_kg: @parcel.chargeable, status: 1, free_storage: Time.now + 15.days)
          end
        end
        mailer = Mailin.new(ENV['SENDINBLUE_API_URL'], ENV['SENDINBLUE_API_KEY'], 5)
        data = {"id" => 15, "to" => @user.email, "attr" => {"NAME" => @user.name}, "headers" => {"Content-Type" => "text/html;charset=iso-8859-1"} }
        result = mailer.send_transactional_template(data)

        if result['code'] == "success"
          flash[:success] = "You've successfully updated the parcel & an email has sent to user"
          redirect_to parcel_path(@parcel)
        end
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
      @parcel = Parcel.new
      authorize @parcel
    end

    # use only for admin to create new parcels for users due sometime seller deliver extra parcels without user acknowledges.
    def admin_create
      @user = User.find_by(ezi_id: parcel_params[:ezi_id].capitalize)
      @user_id = @user.id
      @parcel= Parcel.create(user_id: @user_id , ezi_id: parcel_params[:ezi_id].capitalize, awb: parcel_params[:awb], description: parcel_params[:description], parcel_good: parcel_params[:parcel_good], product_quantity: parcel_params[:product_quantity], product_chinese: parcel_params[:product_chinese], remark: parcel_params[:remark], image: parcel_params[:image], photoshoot: false, inspection: false, price_per_unit: 0)
      authorize @parcel
      if @parcel.persisted?
        @parcel.update_attributes(status: 7, weight: 0.5, width: 1, length: 1, height: 1)
        flash[:success] = "Parcel successfully created"
        redirect_to parcels_path
      else
        flash[:danger] = @parcel.errors.full_messages
        redirect_to '/parcels/parcel_new'
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
