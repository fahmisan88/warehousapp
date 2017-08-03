class BlockSuspendUsersController < ApplicationController

  def index
    @user = User.find(params[:id])
    @status = @user.status

    @status_valid = case @status
    when "Inactive" then "invalid"
    when "Active" then "invalid"
    when "Suspended" then "valid"
    when "Blocked" then "valid"
    when "Expired" then "invalid"
    else "invalid"
    end

    unless @status_valid == "valid"
      session.delete(:id)
      redirect_to root_path
    end



  end
end
