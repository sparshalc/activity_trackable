class ApplicationController < ActionController::Base
  include SetTenantConcern
  include Pagy::Backend
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_request_data
  before_action :authenticate_user!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to root_path
  end
  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :full_name, :company_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :full_name ])
  end

  def store_request_data
    RequestStore.store[:ip_address] = request.remote_ip
    RequestStore.store[:user_agent] = request.user_agent
    RequestStore.store[:request_id] = request.request_id
  end
end
