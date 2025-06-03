class ActivitiesController < ApplicationController
  def index
    @activities = filter_activities
    @pagy, @activities = pagy(@activities, items: 2)
    @users = ActsAsTenant.current_tenant.users.select(:id, :full_name, :email).order(:full_name)
    @activity_types = Activity::ACTIONS.values
  end

  private

  def filter_activities
    activities = Activity.includes(:user).recent

    # Filter by date range
    if params[:date_range].present?
      case params[:date_range]
      when "today"
        activities = activities.in_date_range(Date.current.beginning_of_day, Date.current.end_of_day)
      when "week"
        activities = activities.in_date_range(1.week.ago, Time.current)
      when "month"
        activities = activities.in_date_range(1.month.ago, Time.current)
      when "3months"
        activities = activities.in_date_range(3.months.ago, Time.current)
      end
    end

    # Filter by user
    if params[:user_id].present?
      activities = activities.by_user(params[:user_id])
    end

    # Filter by activity type
    if params[:activity_type].present?
      activities = activities.by_action(params[:activity_type])
    end

    activities
  end
end
