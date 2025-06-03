class Activity < ApplicationRecord
  acts_as_tenant(:company)

  # Constants
  ACTIONS = {
    login: "login",
    logout: "logout",

    give_recognition: "give_recognition",
    receive_recognition: "receive_recognition",

    profile_update: "profile_update",

    company_joined: "company_joined",
    company_left: "company_left",
    role_assigned: "role_assigned",
    role_removed: "role_removed",
    role_switch: "role_switch",

    admin_action: "admin_action"
  }.freeze

  belongs_to :trackable, polymorphic: true
  belongs_to :user

  validates :action, presence: true, inclusion: { in: ACTIONS.values }
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }
  scope :by_action, ->(action) { where(action: action) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_trackable, ->(trackable) { where(trackable: trackable) }
  scope :in_date_range, ->(start_date, end_date) { where(occurred_at: start_date..end_date) }
  scope :for_company, ->(company_id) { where(company_id: company_id) }

  before_validation :set_occurred_at, if: -> { occurred_at.blank? }
  before_save :sanitize_metadata
  before_save :enrich_metadata

  def self.track(trackable:, action:, user: nil, company: nil, metadata: {})
    user ||= trackable.is_a?(User) ? trackable : trackable.try(:user)
    company ||= determine_company(trackable, user)

    return unless company&.activity_tracking?

    create!(
      trackable: trackable,
      user: user,
      company: company,
      action: action,
      metadata: metadata,
      occurred_at: Time.current
    )
  rescue StandardError => e
    Rails.logger.error "Activity tracking failed: #{e.message}"
    nil
  end

  def self.track!(trackable:, action:, user: nil, company: nil, metadata: {})
    track(trackable: trackable, action: action, user: user, company: company, metadata: metadata) ||
      raise("Failed to track activity")
  end

  def trackable_name
    case trackable_type
    when "User"
      trackable.full_name
    when "Recognition"
      "Recognition ##{trackable.id}"
    when "Company"
      trackable.name
    when "CompanyUser"
      "#{trackable.user.full_name} at #{trackable.company.name}"
    when "CompanyUserRole"
      "Role assignment for #{trackable.company_user.user.full_name}"
    else
      "#{trackable_type} ##{trackable_id}"
    end
  end

  def description
    case action
    when "login"
      "#{user.full_name} logged in"
    when "logout"
      "#{user.full_name} logged out"
    when "give_recognition"
      "#{trackable.giver.full_name} gave recognition to #{trackable.recipient.full_name}"
    when "receive_recognition"
      "#{trackable.giver.full_name} gave recognition to #{trackable.recipient.full_name}"
    when "profile_update"
      "#{user.full_name} updated profile"
    when "company_joined"
      "#{user.full_name} joined #{trackable.company.name}"
    when "company_left"
      "#{user.full_name} left #{trackable.company.name}"
    when "role_assigned"
      "#{metadata['role_name']} role assigned to #{user.full_name}"
    when "role_removed"
      "#{metadata['role_name']} role removed from #{user.full_name}"
    when "role_switch"
      "#{user.full_name} switched from #{metadata['old_role']} to #{metadata['new_role']}"
    else
      "#{user.full_name} performed #{action.humanize.downcase}"
    end
  end

  private

  def self.determine_company(trackable, user)
    return trackable if trackable.is_a?(Company)
    return trackable.company if trackable.respond_to?(:company)
    return ActsAsTenant.current_tenant if ActsAsTenant.current_tenant.present?
    return user.current_company if user&.respond_to?(:current_company)
    nil
  end

  def set_occurred_at
    self.occurred_at = Time.current
  end

  def sanitize_metadata
    # TODO:  Remove sensitive data || more can be added here later
    sensitive_keys = %w[password token secret]
    self.metadata = metadata.deep_stringify_keys.reject do |key, _|
      sensitive_keys.any? { |sensitive| key.downcase.include?(sensitive) }
    end
  end

  def enrich_metadata
    if defined?(RequestStore) && RequestStore.store[:current_request]
      request = RequestStore.store[:current_request]
      self.metadata["request_id"] = request.uuid if request.respond_to?(:uuid)
    end

    self.metadata["tracked_at"] = Time.current.iso8601
  end
end
