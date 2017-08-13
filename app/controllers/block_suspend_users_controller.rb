class BlockSuspendUsersController < ApplicationController
  before_action :suspended!
  layout "block_suspend"

  def index
    @title = "Your Account is suspended"
    @user = member_user
    @eziid = @user.ezi_id
    @status = @user.status
    @now = Time.now

    @status_valid = case @status
    when "Inactive" then "invalid"
    when "Active" then "invalid"
    when "Suspended" then "valid"
    when "Blocked" then "valid"
    when "Expired" then "invalid"
    else "invalid"
    end

    if @status_valid == "valid" && @user.releasesuspend_at?
      if @status == "Suspended"
        if @user.releasesuspend_at > @now
          @duration_hour = (((@user.releasesuspend_at - @now)/60)/60)
          @duration_minute = (@duration_hour - @duration_hour.to_i) * 60
          @duration_second = (@duration_minute - @duration_minute.to_i) * 60
          @message = "You have been suspended for #{@duration_hour.to_i} hour(s), #{@duration_minute.to_i} minute(s), #{@duration_second.to_i} second(s)"
        else
          @user.update_attribute(:releasesuspend_at, nil)
            @user.update_attribute(:status, 1)
          redirect_to '/dashboard'
        end
      else
        session.delete(:id)
        flash[:danger] = "Please contact admin"
        redirect_to root_path
      end
    else
      session.delete(:id)
      redirect_to root_path
    end



  end
end
