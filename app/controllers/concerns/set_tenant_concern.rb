module SetTenantConcern
  extend ActiveSupport::Concern

  included do
    set_current_tenant_through_filter

    before_action :set_tenant, if: :user_signed_in?
  end

  private

  def set_tenant
    tenant = begin
      # if already logged in he/she will have selected_company_id
      Company.find(current_user.selected_company_id)
    rescue ActiveRecord::RecordNotFound, StandardError => ex
      # TODO: setting current_user first company for now
      current_user.current_company
    end
    set_current_tenant(tenant)
  end
end
