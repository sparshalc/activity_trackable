class DashboardController < ApplicationController
  def index
    @recent_activities = Activity.recent.count
    @users = User.count
  end
end
