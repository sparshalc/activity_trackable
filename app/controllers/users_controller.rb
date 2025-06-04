class UsersController < ApplicationController
  before_action -> { authorize :user, policy_class: UserPolicy }, only: %i[index discarded discard undiscard]
  before_action :set_user, only: [ :discard, :undiscard ]

  def index
    @users = filter_users
    @pagy, @users = pagy(@users, items: 20)

    respond_to do |format|
      format.html
      format.csv { send_data users_csv(@users), filename: "users-#{Date.current}.csv" }
      format.json { render json: { users: @users } }
    end
  end

  def discarded
    @users = filter_discarded_users
    @pagy, @users = pagy(@users, items: 20)
    render :index
  end

  def discard
    # Prevent users from discarding themselves
    if @user == current_user
      redirect_to users_path, alert: "You cannot discard yourself. Please ask another administrator to perform this action."
      return
    end

    reason = params[:reason].presence || "No reason provided"

    if @user.discard_with_tracking!(reason: reason, discarded_by: current_user)
      redirect_to users_path, notice: "User #{@user.full_name} has been discarded successfully."
    else
      redirect_to users_path, alert: "Failed to discard user."
    end
  rescue => e
    redirect_to users_path, alert: "Error discarding user: #{e.message}"
  end

  def undiscard
    reason = params[:reason].presence || "No reason provided"

    if @user.undiscard_with_tracking!(reason: reason, undiscarded_by: current_user)
      redirect_to users_path, notice: "User #{@user.full_name} has been restored successfully."
    else
      redirect_to users_path, alert: "Failed to restore user."
    end
  rescue => e
    redirect_to users_path, alert: "Error restoring user: #{e.message}"
  end

  private

  def set_user
    @user = User.with_discarded.find(params[:id])
  end

  def filter_users
    users = User.kept.includes(:activities)

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

  def filter_discarded_users
    users = User.discarded.includes(:activities)

    if params[:date_range].present?
      case params[:date_range]
      when "today"
        users = users.where(discarded_at: Date.current.beginning_of_day..Date.current.end_of_day)
      when "week"
        users = users.where(discarded_at: 1.week.ago..Time.current)
      when "month"
        users = users.where(discarded_at: 1.month.ago..Time.current)
      when "3months"
        users = users.where(discarded_at: 3.months.ago..Time.current)
      end
    end

    users.order(:full_name)
  end

  def users_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << [ "Full Name", "Email", "Status", "Total Activities", "Recent Activities", "Last Sign In", "Created At", "Discarded At" ]

      users.each do |user|
        recent_activities = user.activities.where("occurred_at > ?", 7.days.ago).count
        status = user.discarded? ? "Discarded" : (recent_activities > 0 ? "Active" : "Inactive")

        csv << [
          user.full_name,
          user.email,
          status,
          user.activities.count,
          recent_activities,
          user.last_sign_in_at&.strftime("%Y-%m-%d %H:%M:%S"),
          user.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          user.discarded_at&.strftime("%Y-%m-%d %H:%M:%S")
        ]
      end
    end
  end
end
