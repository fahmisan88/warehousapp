class UsersController < ApplicationController

  before_action :authenticate!,  only: [:edit, :update]

  def index

    @users = User.all.order(updated_at: :desc).page params[:page]
      authorize @users
  end

  def show
    @user = User.find_by(id: params[:id])
  end

  def new
    if current_user
      redirect_to '/dashboard'
    else
      @user = User.new
    end
  end

  def create
    if user_params[:password] == user_params[:password2]
      @user = User.create(name: user_params[:name], email: user_params[:email], password: user_params[:password])
      if @user.persisted?
        flash[:success] = "You have register!"
        redirect_to root_path
      else
        redirect_to '/register'
        flash[:danger] = "You have registered!"
      end
    else
      flash[:danger] = "Your password does not match!"
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

  private

  def user_params
    params.require(:user).permit(:phone, :address, :postcode,:password)
  end
end
