FactoryBot.define do
  factory :role do
    association :company
    sequence(:name) { |n| "Role #{n}" }
    description { "A custom role with specific permissions" }
    permissions { PermissionsConfig.default_permissions }

    trait :owner do
      name { "owner" }
      description { "Owner role with full permissions" }
      permissions { PermissionsConfig.permissions_for('owner') }
    end

    trait :admin do
      name { "admin" }
      description { "Admin role with administrative permissions" }
      permissions { PermissionsConfig.permissions_for('admin') }
    end

    trait :manager do
      name { "manager" }
      description { "Manager role with limited administrative permissions" }
      permissions { PermissionsConfig.permissions_for('manager') }
    end

    trait :employee do
      name { "employee" }
      description { "Employee role with basic permissions" }
      permissions { PermissionsConfig.permissions_for('employee') }
    end

    trait :custom do
      sequence(:name) { |n| "custom_role_#{n}" }
      description { "A custom role with specific permissions" }
      permissions do
        # Custom permissions example
        PermissionsConfig.default_permissions.merge(
          'recognitions' => { 'view' => true, 'create' => true }
        )
      end
    end
  end
end
