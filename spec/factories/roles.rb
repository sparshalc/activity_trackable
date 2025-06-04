FactoryBot.define do
  factory :role do
    association :company
    sequence(:name) { |n| "Role #{n}" }
    description { "A custom role with specific permissions" }
    permissions do
      {
        dashboard: { view: true },
        users: { view: false, create: false, update: false, delete: false },
        activities: { view: false },
        recognitions: { view: false, create: false },
        company_settings: { view: false, edit: false },
        user_profile: { view: true },
        company_switcher: { view: true }
      }
    end

    trait :owner do
      name { "owner" }
      description { "Owner role with full permissions" }
      permissions do
        {
          dashboard: { view: true },
          analytics: { view: true },
          users: { view: true, create: true, update: true, delete: true },
          activities: { view: true },
          recognitions: { view: true, create: true },
          company_settings: { view: true, edit: true },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      end
    end

    trait :admin do
      name { "admin" }
      description { "Admin role with administrative permissions" }
      permissions do
        {
          dashboard: { view: true },
          analytics: { view: true },
          users: { view: true, create: true, update: true, delete: true },
          activities: { view: true },
          recognitions: { view: true, create: true },
          company_settings: { view: true, edit: true },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      end
    end

    trait :manager do
      name { "manager" }
      description { "Manager role with limited administrative permissions" }
      permissions do
        {
          dashboard: { view: true },
          analytics: { view: true },
          users: { view: true, update: false },
          activities: { view: true },
          recognitions: { view: true, create: true },
          company_settings: { view: false, edit: false },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      end
    end

    trait :employee do
      name { "employee" }
      description { "Employee role with basic permissions" }
      permissions do
        {
          dashboard: { view: true },
          analytics: { view: false },
          users: { view: false, create: false, update: false, delete: false },
          activities: { view: true },
          recognitions: { view: true, create: false },
          company_settings: { view: false, edit: false },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      end
    end

    trait :custom do
      sequence(:name) { |n| "custom_role_#{n}" }
      description { "A custom role with specific permissions" }
      permissions do
        {
          dashboard: { view: true },
          users: { view: true, create: false, update: false, delete: false },
          activities: { view: true },
          recognitions: { view: true, create: true },
          company_settings: { view: false, edit: false },
          user_profile: { view: true },
          company_switcher: { view: true }
        }
      end
    end
  end
end
