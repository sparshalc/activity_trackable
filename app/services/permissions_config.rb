class PermissionsConfig
  # Define all available resources and their actions
  RESOURCES = {
    dashboard: [ :view ],
    analytics: [ :view ],
    users: [ :view, :create, :update, :delete ],
    activities: [ :view, :export ],
    recognitions: [ :view, :create ],
    company_settings: [ :view, :edit ],
    user_profile: [ :view, :edit ],
    company_switcher: [ :view ]
  }.freeze

  # Default permissions (minimal access)
  DEFAULT_PERMISSIONS = {
    dashboard: { view: true },
    analytics: { view: false },
    users: { view: false, create: false, update: false, delete: false },
    activities: { view: true, export: false },
    recognitions: { view: true, create: false },
    company_settings: { view: false, edit: false },
    user_profile: { view: true, edit: true },
    company_switcher: { view: true }
  }.freeze

  # Role-based permission templates
  ROLE_PERMISSIONS = {
    "owner" => {
      dashboard: { view: true },
      analytics: { view: true },
      users: { view: true, create: true, update: true, delete: true },
      activities: { view: true, export: true },
      recognitions: { view: true, create: true },
      company_settings: { view: true, edit: true },
      user_profile: { view: true, edit: true },
      company_switcher: { view: true }
    },
    "admin" => {
      dashboard: { view: true },
      analytics: { view: true },
      users: { view: true, create: true, update: true, delete: true },
      activities: { view: true, export: true },
      recognitions: { view: true, create: true },
      company_settings: { view: true, edit: true },
      user_profile: { view: true, edit: true },
      company_switcher: { view: true }
    },
    "manager" => {
      dashboard: { view: true },
      analytics: { view: true },
      users: { view: true, create: false, update: false, delete: false },
      activities: { view: true, export: false },
      recognitions: { view: true, create: true },
      company_settings: { view: false, edit: false },
      user_profile: { view: true, edit: true },
      company_switcher: { view: true }
    },
    "employee" => {
      dashboard: { view: true },
      analytics: { view: false },
      users: { view: false, create: false, update: false, delete: false },
      activities: { view: true, export: false },
      recognitions: { view: true, create: false },
      company_settings: { view: false, edit: false },
      user_profile: { view: true, edit: true },
      company_switcher: { view: true }
    }
  }.freeze

  class << self
    # Get permissions for a specific role
    def permissions_for(role_name)
      ROLE_PERMISSIONS[role_name.to_s] || DEFAULT_PERMISSIONS
    end

    # Get default permissions (for fallback)
    def default_permissions
      DEFAULT_PERMISSIONS.deep_dup
    end

    # Get all available resources
    def available_resources
      RESOURCES.keys
    end

    # Get all available actions for a resource
    def available_actions(resource)
      RESOURCES[resource.to_sym] || []
    end

    # Check if a resource/action combination is valid
    def valid_permission?(resource, action)
      RESOURCES.key?(resource.to_sym) &&
        RESOURCES[resource.to_sym].include?(action.to_sym)
    end

    # Get all role names
    def available_roles
      ROLE_PERMISSIONS.keys
    end

    # Compare two permission sets
    def permissions_diff(old_permissions, new_permissions)
      diff = {}

      RESOURCES.each do |resource, actions|
        resource_key = resource.to_s
        actions.each do |action|
          action_key = action.to_s
          old_value = old_permissions.dig(resource_key, action_key)
          new_value = new_permissions.dig(resource_key, action_key)

          if old_value != new_value
            diff[resource_key] ||= {}
            diff[resource_key][action_key] = {
              from: old_value,
              to: new_value
            }
          end
        end
      end

      diff
    end

    # Validate permission structure
    def valid_permissions?(permissions)
      return false unless permissions.is_a?(Hash)

      permissions.all? do |resource, actions|
        next false unless RESOURCES.key?(resource.to_sym)
        next false unless actions.is_a?(Hash)

        actions.all? do |action, value|
          RESOURCES[resource.to_sym].include?(action.to_sym) &&
            [ true, false ].include?(value)
        end
      end
    end

    # Generate a full permission set (with all resources/actions)
    def complete_permissions(base_permissions = {})
      result = {}

      RESOURCES.each do |resource, actions|
        resource_key = resource.to_s
        result[resource_key] = {}

        actions.each do |action|
          action_key = action.to_s
          result[resource_key][action_key] = base_permissions.dig(resource_key, action_key) || false
        end
      end

      result
    end
  end
end
