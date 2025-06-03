class DashboardController < ApplicationController
  def index
    @recent_activities = Activity.recent.count
    @users = User.count
  end

  def switch_company
    if (company_id = params[:company_id]).present? && current_user.present?
      # Verify user has access to this company
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
end
