FactoryBot.define do
  factory :company_user_role do
    association :company_user
    association :role

    trait :admin_assignment do
      after(:build) do |company_user_role|
        company_user_role.role = create(:role, :admin, company: company_user_role.company_user.company)
      end
    end

    trait :manager_assignment do
      after(:build) do |company_user_role|
        company_user_role.role = create(:role, :manager, company: company_user_role.company_user.company)
      end
    end

    trait :employee_assignment do
      after(:build) do |company_user_role|
        company_user_role.role = create(:role, :employee, company: company_user_role.company_user.company)
      end
    end

    trait :owner_assignment do
      after(:build) do |company_user_role|
        company_user_role.role = create(:role, :owner, company: company_user_role.company_user.company)
      end
    end
  end
end
