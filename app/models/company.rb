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

  def active_users_count
    users.kept.count
  end

  def discarded_users_count
    users.discarded.count
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
        permissions: PermissionsConfig.permissions_for(role_name)
      )
    end
  end
end
