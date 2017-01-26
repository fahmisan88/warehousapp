class LandingController < ApplicationController

   def index
     if current_user && current_user.status == "active" && current_user.address?
       redirect_to dashboard_path
     else
       redirect_to edit_user_path(current_user)
     end
   end
 end
