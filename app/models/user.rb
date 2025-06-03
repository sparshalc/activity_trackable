class User < ApplicationRecord
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

  def current_company
    # TODO: user current_company_id on User later.

    companies.first
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
end
