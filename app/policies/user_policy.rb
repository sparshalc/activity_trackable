class UserPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    user.current_role.can?(:users, :view)
  end

  def show?
    user.current_role.can?(:users, :view)
  end

  def discard?
    user.current_role.can?(:users, :update)
  end

  def discarded?
    user.current_role.can?(:users, :update)
  end

  def undiscard?
    user.current_role.can?(:users, :update)
  end

  def resource_name
    "user"
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.current_role.can?(:users, :view)
        scope.all
      else
        scope.none
      end
    end
  end
end
