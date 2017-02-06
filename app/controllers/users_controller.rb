class UsersController < ApplicationController

  before_action :authenticate!,  only: [:edit, :update]

  def index

    @users = User.all.order(updated_at: :desc).page params[:page]
      authorize @users
      if params[:search]
        @users = User.search(params[:search]).order("updated_at DESC").page params[:page]
      else
      end
  end

  def show
    @user = User.find_by(id: params[:id])
  end

  def pay
    @user = User.find_by(id: params[:id])
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
    if @user = User.create(name: reg_user_params[:fullname], email: reg_user_params[:email], password: reg_user_params[:passwd], package: reg_user_params[:package].to_i).valid?
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
  end

  def update
    @user = User.find_by(id: params[:id])
    authorize @user
    if @user.update(user_params)
      flash[:success] = "You have added your address!"
      redirect_to dashboard_path
    else
      flash[:danger] = "Your update failed!"
      render :edit
    end
  end

  def edit_id
    @user = User.find_by(id: params[:id])
  end

  def update_id
    @user = User.find_by(id: params[:id])
    if @user.update(edit_params)
      flash[:success] = "You have updated the user information!"
      redirect_to users_path
    else
      flash[:danger] = "Your update failed!"
      render :edit
    end
  end

  def suspend
    @user= User.find_by(id: params[:id])
    if @user.update_attribute(:status, 2)
      flash[:success] = "You've suspend a user."
      redirect_to users_path
    else
      flash[:danger]
      redirect_to users_path
    end
  end

  def block
    @user= User.find_by(id: params[:id])
    if @user.update_attribute(:status, 3)
      redirect_to users_path
      flash[:success] = "You've block a user."
    else
      flash[:danger]
      redirect_to users_path
    end
  end

  def activate
    @user= User.find_by(id: params[:id])
    if @user.update_attribute(:status, 1)
      redirect_to users_path
      flash[:success] = "You've activate a user."
    else
      flash[:danger]
      redirect_to users_path
    end
  end

  def emailcheck
    @user = User.find_by(email: reg_user_params[:email])
    if @user.present?
      flash[:danger] = "Package is not available"
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
      flash[:danger] = "Package is not available"
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

  def edit_params
    params.require(:user).permit(:ezi_id, :expiry)
  end

end
