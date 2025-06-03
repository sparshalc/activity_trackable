class Company < ApplicationRecord
  include Trackable

  has_many :company_users, dependent: :destroy
  has_many :users, through: :company_users
  has_many :roles, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_one :company_setting, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  after_create :create_default_settings
  after_create :create_default_roles

  delegate :activity_tracking, :activity_tracking?, :activity_retention_days, to: :company_setting

  def add_user(user, role_name = "employee")
    company_user = company_users.create!(user: user, joined_at: Time.current)

    role = roles.find_by(name: role_name) || roles.find_by(name: "employee")
    if role
      company_user.assign_role(role)
      company_user.update!(current_role: role)
    end

    company_user
  end

  def remove_user(user)
    company_users.find_by(user: user)&.destroy
  end

  private

  def create_default_settings
    create_company_setting!(activity_retention_days: 2)
  end

  def create_default_roles
    [ "owner", "admin", "manager", "employee" ].each do |role_name|
      roles.create!(
        name: role_name,
        description: "#{role_name.capitalize} role",
        permissions: default_permissions_for(role_name)
      )
    end
  end

  def default_permissions_for(role_name)
    case role_name
    when "owner", "admin"
      {
        activities: { view: true, export: true },
        users: { view: true, create: true, update: true, delete: true },
        company: { view: true, update: true },
        roles: { view: true, create: true, update: true, delete: true }
      }
    when "manager"
      {
        activities: { view: true, export: true },
        users: { view: true, create: true, update: true, delete: false },
        company: { view: true, update: false },
        roles: { view: true, create: false, update: false, delete: false }
      }
    else # employee
      {
        activities: { view: false, export: false },
        users: { view: true, create: false, update: false, delete: false },
        company: { view: true, update: false },
        roles: { view: false, create: false, update: false, delete: false }
      }
    end
  end
end
