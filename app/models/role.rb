class Role < ApplicationRecord
  acts_as_tenant(:company)

  DEFAULT_PERMISSIONS = {
    activities: { view: false, export: false },
    users: { view: false, create: false, update: false, delete: false },
    company: { view: false, update: false },
    roles: { view: false, create: false, update: false, delete: false }
  }.freeze

  has_many :company_user_roles, dependent: :restrict_with_error
  has_many :company_users, through: :company_user_roles
  has_many :current_role_users, class_name: "CompanyUser", foreign_key: :current_role_id

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :permissions, presence: true

  before_validation :set_default_permissions

  def can?(resource, action)
    return false unless permissions.present?
    permissions.dig(resource.to_s, action.to_s) == true
  end

  def update_permission(resource, action, value)
    self.permissions ||= DEFAULT_PERMISSIONS.deep_dup
    self.permissions[resource.to_s] ||= {}
    self.permissions[resource.to_s][action.to_s] = value
    save
  end

  private

  def set_default_permissions
    self.permissions ||= DEFAULT_PERMISSIONS.deep_dup
  end
end
