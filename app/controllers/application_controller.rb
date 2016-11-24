class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery with: :exception

  rescue_from Pundit::NotAuthorizedError do |exception|
    flash[:danger] = "You're not authorized"
    redirect_to request.referrer || root_path
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


  def current_user
    return unless session[:id]
    @current_user ||= User.find_by(id: session[:id])
  end
  helper_method :current_user


  def authenticate!
    unless current_user
      redirect_to root_path
      flash[:danger] = "You need to login first"
    end

  end
end
