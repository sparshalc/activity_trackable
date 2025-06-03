class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_request_data

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :company_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def store_request_data
    RequestStore.store[:ip_address] = request.remote_ip
    RequestStore.store[:user_agent] = request.user_agent
    RequestStore.store[:request_id] = request.request_id
  end
end
