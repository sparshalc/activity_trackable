class UsersController < ApplicationController
  def index
    @users = filter_users
    @pagy, @users = pagy(@users, items: 20)

    respond_to do |format|
      format.html
      format.csv { send_data users_csv(@users), filename: "users-#{Date.current}.csv" }
    end
  end

  private

  def filter_users
    users = User.includes(:activities)

    # Filter by date range (based on user creation date)
    if params[:date_range].present?
      case params[:date_range]
      when "today"
        users = users.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
      when "week"
        users = users.where(created_at: 1.week.ago..Time.current)
      when "month"
        users = users.where(created_at: 1.month.ago..Time.current)
      when "3months"
        users = users.where(created_at: 3.months.ago..Time.current)
      end
    end

    # Filter by activity level
    if params[:activity_level].present?
      case params[:activity_level]
      when "active"
        users = users.joins(:activities).where(activities: { occurred_at: 7.days.ago..Time.current }).distinct
      when "inactive"
        active_user_ids = Activity.where(occurred_at: 7.days.ago..Time.current).distinct.pluck(:user_id)
        users = users.where.not(id: active_user_ids)
      end
    end

    users.order(:full_name)
  end

  def users_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << [
        "Full Name",
        "Email",
        "Total Activities",
        "Recent Activities (7 days)",
        "Last Sign In",
        "Sign In Count",
        "Joined Date"
      ]

      users.each do |user|
        recent_activities_count = user.activities.where("occurred_at > ?", 7.days.ago).count
        last_sign_in = user.last_sign_in_at ? user.last_sign_in_at.strftime("%Y-%m-%d %H:%M:%S") : "Never"

        csv << [
          user.full_name,
          user.email,
          user.activities.count,
          recent_activities_count,
          last_sign_in,
          user.sign_in_count,
          user.created_at.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
  end
end
