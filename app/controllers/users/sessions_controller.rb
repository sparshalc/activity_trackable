class Users::SessionsController < Devise::SessionsController
  before_action :track_logout_before_destroy, only: [ :destroy ]

  protected

  def after_sign_in_path_for(resource)
    resource.track_login(request) if resource.is_a?(User)
    super
  end

  private

  def track_logout_before_destroy
    # Track logout before the user is actually signed out
    if user_signed_in? && current_user.is_a?(User)
      current_user.track_logout(request)
    end
  end
end
