class SessionsController < ApplicationController


def new
end

def create
  user = User.find_by(email: user_params[:email].downcase)
             &.authenticate(user_params[:password])
  if user && (user.role == "admin" || user.role == "staff")
    session[:id] = user.id
    flash[:success] = "Welcome back Admin"
    redirect_to admin_dashboards_path
  elsif user && user.status == "Active" && user.address?
    session[:id] = user.id
    flash[:success] = "Welcome back #{current_user.name}"
    redirect_to dashboards_path
  elsif user && user.status == "Active" && user.address.nil?
    session[:id] = user.id
    flash[:success] = "Please add your address before proceed"
    redirect_to edit_user_path(user.id)
  elsif user && user.status == "Inactive"
    session[:id] = user.id
    flash[:success] = "Please pay our yearly fee to continue using our service"
    redirect_to pay_user_path(user.id)
  elsif user && user.status == "Expired"
    session[:id] = user.id
    flash[:success] = "Please pay your renewal fee to continue using our service"
    redirect_to '/renew'
  elsif user && user.status == "Suspended"
    session[:id] = user.id
    redirect_to '/suspend'
  else
    reset_session
    flash[:danger] = "Wrong Credential"
    redirect_to '/login'
  end

end

def destroy
  reset_session
  flash[:success] = "You've been logged out"
  redirect_to root_path
end

private

def user_params
  params.require(:user).permit(:email, :password)
end

end
