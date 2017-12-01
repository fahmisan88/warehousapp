class Admin::SystemsettingsController < ApplicationController
  before_action :authenticate!
  before_action :check_if_admin

  def index
  end

  def edit
    @page_title = "System Settings"
    @registration = SystemConfig.registration
  end

  def update

    # @setting = SystemConfig.find_by(var: "registration")
    @registration = SystemConfig.find_by(var: "registration") || SystemConfig.new(var: "registration")

    if @registration.value != setting_params[:registration]
      @registration.value = setting_params[:registration]
      @registration.save
      flash[:success] = "Settings Saved"
      redirect_to "/admin/setting"
    else
      if @registration.value == setting_params[:registration]
        flash[:normal] = "Nothing is saved"
        redirect_to "/admin/setting"
      else
        flash[:danger] = "something is wrong"
        redirect_to "/admin/setting"
      end
    end
  end

  private

  def setting_params
    params.require(:setting).permit(:registration)
  end

end
