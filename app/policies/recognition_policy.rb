class RecognitionPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    user.current_role.can?(:recognitions, :view)
  end

  def show?
    user.current_role.can?(:recognitions, :view)
  end

  def new?
    user.current_role.can?(:recognitions, :create)
  end

  def create?
    new?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.admin? || user.owner?
        # Admin and owner can see all recognitions in their company
        scope.all
      elsif user.manager?
        scope.where(recipient: user).or(scope.where(giver: user))
      else
        scope.where(recipient: user)
      end
    end
  end
end
