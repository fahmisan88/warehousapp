class LandingController < ApplicationController

   def index
     if current_user && current_user.status == "active"
       redirect_to dashboard_path
     else
     end
   end
 end
