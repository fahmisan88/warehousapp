class Admin::UsersController < ApplicationController
  before_action :check_if_admin


  def index
    @filter_params = params[:status]
    @users = User.all.order(updated_at: :desc).page params[:page]
    authorize @users

      if @filter_params == "Inactive"
        @users = User.where(status: 0).order("created_at desc").page(params[:page])
      elsif @filter_params == "Active"
        @users = User.where(status: 1).order("created_at desc").page(params[:page])
  		elsif @filter_params == "Suspended"
        @users = User.where(status: 2).order("created_at desc").page(params[:page])
      elsif @filter_params == "Blocked"
        @users = User.where(status: 3).order("created_at desc").page(params[:page])
      elsif @filter_params == "Expired"
        @users = User.where(status: 4).order("created_at desc").page(params[:page])
      end

      if params[:search]
          @users = User.search(params[:search]).order("updated_at DESC").page params[:page]
      end

  end

  def show
    @user = User.find_by(id: params[:id])
  end

  def edit
    @user = User.find_by(id: params[:id])
  end

  def edit_id
    @user = User.find_by(id: params[:id])
  end

  def update
    @user = User.find_by(id: params[:id])
    authorize @user
    if @user.update(user_params)
      flash[:success] = "Address updated"
      redirect_to admin_users_path
    else
      flash[:danger] = "Your update failed!"
      render :edit
    end
  end

  def update_id
    @user = User.find_by(id: params[:id])
    if @user.update(edit_params)
      flash[:success] = "You have updated the user information!"
      redirect_to admin_users_path
    else
      flash[:danger] = "Your update failed!"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:phone, :address, :address2, :postcode, :city)
  end

  def edit_params
    params.require(:user).permit(:ezi_id, :expiry)
  end

end
