class LandingController < ApplicationController

   def index
     if current_user && current_user.status == "active" && current_user.address?
       redirect_to dashboard_path
     elsif current_user && current_user.status == "active" && current_user.address.empty?
       redirect_to edit_user_path(current_user)
     else
     end
   end
 end
