class Role < ApplicationRecord
  has_many :company_user_roles, dependent: :restrict_with_error
  has_many :company_users, through: :company_user_roles
  has_many :current_role_users, class_name: "CompanyUser", foreign_key: :current_role_id

  belongs_to :company

  validates :name, presence: true, uniqueness: { scope: :company_id }
  validates :permissions, presence: true

  before_validation :set_default_permissions

  def can?(resource, action)
    return false unless permissions.present?
    permissions.dig(resource.to_s, action.to_s) == true
  end

  def update_permission(resource, action, value)
    # Validate the permission is valid before updating
    unless PermissionsConfig.valid_permission?(resource, action)
      raise ArgumentError, "Invalid permission: #{resource}.#{action}"
    end

    self.permissions ||= PermissionsConfig.default_permissions
    self.permissions[resource.to_s] ||= {}
    self.permissions[resource.to_s][action.to_s] = value
    save
  end

  # Get the default permissions template for a role name
  def self.default_permissions_for(role_name)
    PermissionsConfig.permissions_for(role_name)
  end

  # Validate that permissions match the expected structure
  def valid_permissions?
    PermissionsConfig.valid_permissions?(permissions)
  end

  # Get a list of all permissions this role has
  def granted_permissions
    result = []
    permissions.each do |resource, actions|
      actions.each do |action, granted|
        result << "#{resource}.#{action}" if granted
      end
    end
    result
  end

  # Check if this role has any admin-level permissions
  def admin_level?
    can?(:users, :update) || can?(:company_settings, :edit)
  end

  private

  def set_default_permissions
    if permissions.blank?
      # Use role-specific template if available, otherwise use default
      self.permissions = PermissionsConfig.permissions_for(name)
    end
  end
end
