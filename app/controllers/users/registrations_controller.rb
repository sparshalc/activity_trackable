class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!

  # GET /users/edit
  def edit
    super
  end

  # PATCH/PUT /users
  def update
    # Track what fields are being changed
    changed_fields = []
    changed_fields << "full_name" if params[:user][:full_name] != resource.full_name

    # Store original values for tracking
    original_full_name = resource.full_name

    # Call the parent update method
    super do |resource|
      if resource.persisted? && resource.errors.empty?
        # Track the profile update activity
        track_profile_update(resource, changed_fields, original_full_name)
      end
    end
  end

  protected

  def update_resource(resource, params)
    # Allow updating without current password if only updating full_name
    if params[:password].blank? && params[:password_confirmation].blank?
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end

  private

  def track_profile_update(user, changed_fields, original_full_name)
    return if changed_fields.empty?

    metadata = {
      changed_fields: changed_fields,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      request_id: request.request_id
    }

    # Add specific change details to metadata
    if changed_fields.include?("full_name")
      metadata[:full_name_changed] = {
        from: original_full_name,
        to: user.full_name
      }
    end

    if changed_fields.include?("password")
      metadata[:password_changed] = true
      metadata[:password_changed_at] = Time.current.iso8601
    end

    # Track the activity
    user.track_activity("profile_update", metadata: metadata)
  end
end
