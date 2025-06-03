class DashboardController < ApplicationController
  def index
    @activities = Activity.recent
    @users = User.count
  end

  def analytics
    @date_range = params[:date_range] || "30"
    @start_date = @date_range.to_i.days.ago.beginning_of_day
    @end_date = Time.current.end_of_day

    @total_activities = Activity.in_date_range(@start_date, @end_date).count
    @activities_by_day = Activity.in_date_range(@start_date, @end_date)
                                .group_by_day(:occurred_at)
                                .count

    @activities_by_type = Activity.in_date_range(@start_date, @end_date)
                                 .group(:action)
                                 .count

    @total_users = User.count
    @new_users = User.where(created_at: @start_date..@end_date).count
    @users_by_day = User.where(created_at: @start_date..@end_date)
                       .group_by_day(:created_at)
                       .count

    @login_activities = Activity.by_action("login")
                               .in_date_range(@start_date, @end_date)
    @unique_daily_users = @login_activities.group_by_day(:occurred_at)
                                          .distinct
                                          .count(:user_id)

    @top_users = Activity.in_date_range(@start_date, @end_date)
                        .joins(:user)
                        .group("users.full_name", "users.id")
                        .count
                        .sort_by { |_, count| -count }
                        .first(10)

    @browser_stats = Activity.in_date_range(@start_date, @end_date)
                            .where.not("metadata->>'user_agent' IS NULL")
                            .group("metadata->>'user_agent'")
                            .count
                            .transform_keys { |ua| parse_user_agent_detailed(ua) }
                            .each_with_object(Hash.new(0)) { |(browser, count), hash| hash[browser] += count }
                            .sort_by { |_, count| -count }
                            .first(5)

    @peak_hours = Activity.in_date_range(@start_date, @end_date)
                         .group("EXTRACT(hour FROM occurred_at)")
                         .count
                         .sort_by { |hour, _| hour.to_i }
  end

  def switch_company
    if (company_id = params[:company_id]).present? && current_user.present?
      if current_user.company_users.exists?(company_id: company_id)
        current_user.update(selected_company_id: company_id)
        redirect_to dashboard_path, notice: "Company switched successfully"
      else
        redirect_to dashboard_path, alert: "You do not have access to that company"
      end
    else
      redirect_to dashboard_path, alert: "Invalid company selection"
    end
  end

  private

  def parse_user_agent_detailed(user_agent)
    return "Unknown" if user_agent.blank?

    case user_agent
    when /Firefox\/(\d+)/
      "Firefox #{$1}"
    when /Chrome\/(\d+)/
      "Chrome #{$1.split('.').first}"
    when /Safari\/(\d+)/
      "Safari"
    when /Edge\/(\d+)/
      "Edge #{$1}"
    when /Opera\/(\d+)/
      "Opera #{$1}"
    else
      "Other"
    end
  end
end
