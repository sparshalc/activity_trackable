class User < ApplicationRecord
  include Discard::Model
  include Trackable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_many :company_users, dependent: :destroy
  has_many :companies, through: :company_users
  has_many :activities, dependent: :nullify

  validates :full_name, presence: true
  before_create :build_company_user_and_set_company

  def active_for_authentication?
    super && !discarded?
  end

  def inactive_message
    discarded? ? :discarded : super
  end

  def current_company
    # TODO: user current_company_id on User later.

    ActsAsTenant.current_tenant || companies.first
  end

  def current_role
    company_users.find_by(company: current_company)&.current_role
  end

  def admin?
    current_role&.name == "admin"
  end

  def owner?
    current_role&.name == "owner"
  end

  def manager?
    current_role&.name == "manager"
  end

  def role_in_company(company)
    company_users.find_by(company: company)&.current_role
  end

  def switch_role_in_company(company, role)
    company_user = company_users.find_by(company: company)
    company_user&.switch_role(role)
  end

  def companies_where_admin
    companies.joins(company_users: :current_role)
             .where(roles: { name: [ "admin", "owner" ] })
  end

  def all_activities
    Activity.where("trackable_type = ? AND trackable_id = ? OR user_id = ?",
                   "User", id, id)
            .recent
  end

  def track_login(request = nil)
    metadata = build_auth_metadata(request, :login)
    track_activity("login", metadata: metadata)
  end

  def track_logout(request = nil)
    metadata = build_auth_metadata(request, :logout)
    track_activity("logout", metadata: metadata)
  end

  def discard_with_tracking!(reason: nil, discarded_by: nil)
    metadata = {
      reason: reason,
      discarded_by_id: discarded_by&.id,
      discarded_by_name: discarded_by&.full_name,
      discarded_at: Time.current.iso8601
    }

    discard!
    track_activity("user_discarded", user: discarded_by || self, metadata: metadata)
  end

  def undiscard_with_tracking!(reason: nil, undiscarded_by: nil)
    was_discarded_duration = discarded_at ? ((Time.current - discarded_at) / 1.day).round : nil

    metadata = {
      reason: reason,
      undiscarded_by_id: undiscarded_by&.id,
      undiscarded_by_name: undiscarded_by&.full_name,
      undiscarded_at: Time.current.iso8601,
      was_discarded_for_days: was_discarded_duration
    }

    undiscard!
    track_activity("user_undiscarded", user: undiscarded_by || self, metadata: metadata)
  end

  private

  def calculate_session_duration
    return 0 unless current_sign_in_at
    (Time.current - current_sign_in_at).to_i
  end

  def build_auth_metadata(request, action_type)
    metadata = {}

    if request
      metadata[:ip_address] = request.remote_ip
      metadata[:user_agent] = request.user_agent
      metadata[:referrer] = request.referrer
    end

    case action_type
    when :login
      metadata[:login_method] = last_sign_in_at ? "returning" : "first_time"
    when :logout
      metadata[:session_duration] = calculate_session_duration
    end

    metadata
  end

  def build_company_user_and_set_company
    company_users.build(company_id: ActsAsTenant.current_tenant.id)
    self.selected_company_id ||= ActsAsTenant.current_tenant.id
  end
end
