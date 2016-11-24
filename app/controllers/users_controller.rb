class UsersController < ApplicationController

  before_action :authorize, except: [:new, :create ]

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
        puts @user.errors.full_messages
      end
    else
      puts "password not match"
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

      redirect_to dashboard_path
    else
      render :edit
    end
  end

  def destroy
    authorize @user
  end

  private

  def user_params
    params.require(:user).permit(:name, :phone, :address, :postcode, :email, :password, :password2)
  end
end
