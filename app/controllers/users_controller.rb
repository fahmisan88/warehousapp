class UsersController < ApplicationController

  before_action :authenticate!,  only: [:edit, :update]

  def show
    @user = User.find_by(id: params[:id])
    authorize @user
  end

  def pay
    @user = User.find_by(id: params[:id])
  end

  def renew
    if member_user&.status == "Expired"
      if member_user.expiry < Time.now
        @user = member_user
        if @user.package?
          @user_package = case @user.package
            when 1 then "1 year subscription = RM150"
            when 2 then "2 years subscription = RM250"
            else "2 years subscription = RM250"
          end
        end
      else
        flash[:success] = "Your membership are still active"
        redirect_to '/dashboard'
      end
    else
      session.delete(:id)
      redirect_to root_path
    end
  end

  def update_package
    @package = package_params[:package]
    if (1..2).include? @package.to_i
      # member_user.update_attribute(:package, @package.to_i)
      respond_to do |format|
        format.json { render json: { valid: true } }
      end
    else
      respond_to do |format|
        format.json { render json: { valid: false, message: "Package is not available" } }
      end
    end
  end

  def billplz_getbill
    if member_user&.status == "Expired" && member_user.bill_id?
      redirect_to member_user.bill_url
    else
      reset_session
      redirect_to root_path
    end
  end

  def billplz_bill_renewal
    @user = member_user

    if package_params
      @package = package_params[:package].to_i
    else
      redirect_to '/renew'
    end

    if @user.package.nil? || @user.package == 0
      @user.update_attribute(:package, @package)
    end

    if !@user.bill_id? && @user.status == "Expired"
      @bill = BillplzRenewal.create_bill_for(@user.id)
      @user.update_attribute(:bill_id, @bill.parsed_response['id'])
      @user.update_attribute(:bill_url, @bill.parsed_response['url'])
      @user.update_attribute(:package, @package)
      redirect_to @bill.parsed_response['url']
    elsif @user.bill_id? && @user.status == "Expired"
      redirect_to @user.bill_url
    else
      redirect_to root_path
    end
  end

  def billplz
    @user = User.find_by(id: params[:id])
    if @bill = BillplzReg.create_bill_for(@user)
      @user.update_attribute(:bill_id, @bill.parsed_response['id'])
      @user.update_attribute(:bill_url, @bill.parsed_response['url'])
      redirect_to @bill.parsed_response['url']
    else
      redirect_to pay_user_path
    end
  end

  def edit_ewallet
    @user = User.find_by(id: params[:id])
  end

  def update_ewallet
    @user = User.find_by(id: params[:id])
    if @user.update(:ewallet)
      flash[:success] = "You have updated the user's balance e-wallet"
      redirect_to user_path
    else
      flash[:danger] = "Update balance failed"
      render new_ewallet_user_path
    end
  end

  def new
    if current_user && current_user.status == "Active"
      redirect_to root_path
    else
      @user = User.new
    end
  end

  def create
    if @user = User.create(name: reg_user_params[:fullname], email: reg_user_params[:email].downcase, password: reg_user_params[:passwd], package: reg_user_params[:package].to_i).valid?
      flash[:success] = "You are registered. Please login and pay the yearly fee to continue using our service."
      redirect_to new_session_path
    else
      flash[:danger] = "You are not successfully registered. Please contact admin."
      redirect_to '/register'
    end

  end

#edit and update method is for adding address for user
  def edit
    @user = User.find_by(id: params[:id])
    authorize @user
    if @user.address?
      flash[:danger] = "If you want to change your address please contact admin"
      redirect_to dashboards_path
    end
  end

  def update
    @user = User.find_by(id: params[:id])
    authorize @user
    if @user.update(user_params)
      flash[:success] = "Address updated"
      redirect_to dashboards_path
    else
      flash[:danger] = "Your update failed!"
      render :edit
    end
  end

  def suspend
    @user= User.find_by(id: params[:id])
    @duration = params[:duration].to_i
    if @user.update_attribute(:status, 2) && @user.update_attribute(:releasesuspend_at, Time.now + @duration)
      respond_to do |format|
        format.json {render json: { status: "success", message: "The user was successfully suspended."}, status: :ok}
      end
    else
      respond_to do |format|
        format.json {render json: { status: "error", message: "The user was not successfully suspended. Please contact the app developer"}, status: :ok}
      end
    end
  end

  def block
    @user= User.find_by(id: params[:id])
    if @user.update_attribute(:status, 3)
      flash[:success] = "You've block a user."
    else
      flash[:danger] = "Action failed"
    end
    redirect_to admin_users_path

  end

  def activate
    @user= User.find_by(id: params[:id])
    if @user.update_attribute(:status, 1)
      flash[:success] = "You've activate a user."
    else
      flash[:danger] = "Action failed"
    end
    redirect_to admin_users_path

  end

# ajax check existing email on registration form
  def emailcheck
    @user = User.find_by(email: reg_user_params[:email].downcase)
    if @user.present?
      respond_to do |format|
        format.json {render json: { valid: false, message: "This email is already registered" }}
      end
    else
      respond_to do |format|
        format.json {render json: { valid: true}}
      end
    end
  end


# check validation choosen package at registration form
  def packagecheck
    @package = reg_user_params[:package]
    if (1..3).include? @package.to_i
      respond_to do |format|
        format.json { render json: { valid: true } }
      end
    else
      respond_to do |format|
        format.json { render json: { valid: false, message: "Package is not available" } }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:phone, :address, :address2, :postcode)
  end

  def reg_user_params
    params.require(:user).permit(:email, :passwd, :fullname, :package)
  end

  def package_params
    params.require(:user).permit(:package)
  end

end
