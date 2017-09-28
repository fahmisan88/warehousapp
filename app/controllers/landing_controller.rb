class LandingController < ApplicationController

   def index
     if current_user && (current_user.role == "admin" || current_user.role == "staff")
       redirect_to admin_dashboards_path
     elsif current_user && current_user.status == "Active" && current_user.address?
       redirect_to dashboards_path
     elsif current_user && current_user.status == "Active" && current_user.address.empty?
       redirect_to edit_user_path(current_user)
     else
     end
   end
 end
