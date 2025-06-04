class DashboardPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  def index?
    # Every user can view the dashboard
    true
  end

  def analytics?
    user.current_role.can?(:analytics, :view)
  end

  def switch_company?
    user.current_role.can?(:company_switcher, :view)
  end

  def resource_name
    "dashboard"
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if admin_and_above?
        scope.all
      else
        scope.none
      end
    end
  end
end
