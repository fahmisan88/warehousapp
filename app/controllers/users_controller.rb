class UsersController < ApplicationController

  before_action :authenticate!,  only: [:edit, :update]

  def index

    @users = User.all.order(updated_at: :desc).page params[:page]
      authorize @users
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
    if current_user
      redirect_to '/dashboard'
    else
      @user = User.new
    end
  end

  def create
    if @user = User.create(name: reg_user_params[:fullname], email: reg_user_params[:email], password: reg_user_params[:passwd]).valid?
      flash[:success] = "You are registered. Please login and pay the yearly fee to continue using our service."
      redirect_to new_session_path
    else
      flash[:danger] = "You are not successfully registered. Please contact admin."
      redirect_to '/register'
    end

  end

  def edit
    @user = User.find_by(id: params[:id])
    authorize @user
  end

  def update
    @user = User.find_by(id: params[:id])
    authorize @user
    if @user.update(user_params)
      flash[:success] = "You have update your account!"
      redirect_to user_path
    else
      flash[:danger] = "Your update failed!"
      render :edit
    end
  end

  def destroy
    authorize @user
  end

  def emailcheck
    @user = User.find_by(email: reg_user_params[:email])

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

  private

  def user_params
    params.require(:user).permit(:phone, :address, :postcode,:password,:email)
  end

  def reg_user_params
    params.require(:user).permit(:email, :passwd, :fullname)
  end

end
