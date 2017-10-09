class IdentitycardsController < ApplicationController
  before_action :authenticate!,  only: [:new, :create]

  def index
  end

  def show
  end

  def new
    @user = member_user
  end

  def create
    @user = member_user
    if @user.update_attributes(photo_params)
      flash[:success] = "Identity card/passport was successfully uploaded."
      redirect_to '/dashboard'
    else
      # flash[:danger] = "This format file is prohibited from being upload"
      @user.errors.each do |attribute, message|
        flash[:danger] = message.to_s
      end
      redirect_to '/ic/upload'
    end
  end

  private

  def photo_params
      params.require(:user).permit(:icpassport)
  end

end
