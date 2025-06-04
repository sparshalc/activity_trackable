class CompanySettingsController < ApplicationController
  before_action -> { authorize :company_setting, policy_class: CompanySettingPolicy }, only: %i[show edit update]
  before_action :set_company_setting

  def show;  end

  def edit; end

  def update
    if @company_setting.update(company_setting_params)
      redirect_to company_settings_path, notice: "Settings updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_company_setting
    @company = ActsAsTenant.current_tenant

    @company_setting = @company.company_setting
  end

  def company_setting_params
    params.require(:company_setting).permit(:activity_tracking, :activity_retention_days)
  end
end
