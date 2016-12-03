class ActivitiesController < ApplicationController
  def index
    if admin_user || staff_user
    @activities = PublicActivity::Activity.order("created_at desc").page params[:page]
    else
    @activities = PublicActivity::Activity.order("created_at desc").where(owner_id: current_user).page params[:page]
    end
  end
end
