class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError do |exception|
    flash[:danger] = "You're not authorized"
    redirect_to request.referrer || root_path
  end

  # check if user is an admin
  def check_if_admin
    if current_user.role == "admin" || current_user.role == "staff"
    else
      flash[:danger] = 'Sorry, only admins allowed!' unless current_user.role == "admin" || current_user.role == "staff"
      redirect_to root_path
    end
  end

  private

  def admin_user
    return unless session[:id]
    @admin_user ||= User.find_by(id: session[:id], role: 2)
  end
  helper_method :admin_user

  def staff_user
    return unless session[:id]
    @staff_user ||= User.find_by(id: session[:id], role: 1)
  end
  helper_method :staff_user

  def member_user
    return unless session[:id]
    @member_user ||= User.find_by(id: session[:id], role: 0)
  end
  helper_method :member_user

  def current_user
    return unless session[:id]
    @current_user ||= User.find_by(id: session[:id])
  end
  helper_method :current_user


  def authenticate!
    unless current_user&.status == "Active"
      session.delete(:id)
      redirect_to root_path
      flash[:danger] = "You need to login first"
    end
  end

# authenticate for suspended users
  def suspended!
    unless current_user&.status == "Suspended"
      session.delete(:id)
      redirect_to root_path
      flash[:danger] = "You need to login first"
    end
  end

  # check existing of user on ezicargo code
  def ezicode_exist
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
  helper_method :ezicode_exist

end
