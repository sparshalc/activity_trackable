class CompanySettingPolicy < ApplicationPolicy
  def show?
    user.current_role.can?(:company_settings, :view)
  end

  def edit?
    user.current_role.can?(:company_settings, :edit)
  end

  def update?
    edit?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if admin_and_above?
        # Only admin and owner can see company settings
        scope.all
      else
        # Other users cannot see company settings
        scope.none
      end
    end
  end
end
