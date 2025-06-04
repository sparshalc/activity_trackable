FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:full_name) { |n| "User #{n}" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :with_tracking_data do
      sign_in_count { 5 }
      current_sign_in_at { 1.hour.ago }
      last_sign_in_at { 1.day.ago }
      current_sign_in_ip { '192.168.1.1' }
      last_sign_in_ip { '192.168.1.2' }
    end

    trait :discarded do
      discarded_at { 1.hour.ago }
    end

    trait :admin do
      after(:create) do |user|
        company = ActsAsTenant.current_tenant || create(:company, :fully_setup)
        company_user = create(:company_user, user: user, company: company)
        admin_role = company.roles.find_by(name: 'admin') || create(:role, :admin, company: company)
        company_user.assign_role(admin_role)
      end
    end

    trait :owner do
      after(:create) do |user|
        company = ActsAsTenant.current_tenant || create(:company, :fully_setup)
        company_user = create(:company_user, user: user, company: company)
        owner_role = company.roles.find_by(name: 'owner') || create(:role, :owner, company: company)
        company_user.assign_role(owner_role)
      end
    end

    trait :manager do
      after(:create) do |user|
        company = ActsAsTenant.current_tenant || create(:company, :fully_setup)
        company_user = create(:company_user, user: user, company: company)
        manager_role = company.roles.find_by(name: 'manager') || create(:role, :manager, company: company)
        company_user.assign_role(manager_role)
      end
    end

    trait :employee do
      after(:create) do |user|
        company = ActsAsTenant.current_tenant || create(:company, :fully_setup)
        company_user = create(:company_user, user: user, company: company)
        employee_role = company.roles.find_by(name: 'employee') || create(:role, :employee, company: company)
        company_user.assign_role(employee_role)
      end
    end
  end
end
