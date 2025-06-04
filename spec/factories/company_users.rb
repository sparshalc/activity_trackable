FactoryBot.define do
  factory :company_user do
    association :company
    association :user
    joined_at { Time.current }

    trait :with_role do
      after(:create) do |company_user|
        role = create(:role, :employee, company: company_user.company)
        company_user.assign_role(role)
      end
    end

    trait :with_admin_role do
      after(:create) do |company_user|
        role = create(:role, :admin, company: company_user.company)
        company_user.assign_role(role)
      end
    end

    trait :with_manager_role do
      after(:create) do |company_user|
        role = create(:role, :manager, company: company_user.company)
        company_user.assign_role(role)
      end
    end

    trait :with_owner_role do
      after(:create) do |company_user|
        role = create(:role, :owner, company: company_user.company)
        company_user.assign_role(role)
      end
    end

    trait :with_multiple_roles do
      after(:create) do |company_user|
        employee_role = create(:role, :employee, company: company_user.company)
        manager_role = create(:role, :manager, company: company_user.company)
        company_user.assign_role(employee_role)
        company_user.assign_role(manager_role)
      end
    end

    trait :recently_joined do
      joined_at { 1.day.ago }
    end

    trait :long_time_member do
      joined_at { 2.years.ago }
    end
  end
end
