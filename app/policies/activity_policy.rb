class ActivityPolicy < ApplicationPolicy
  def index?
    user.current_role.can?(:activities, :view)
  end

  def resource_name
    "activity"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if admin_and_above?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end
end
