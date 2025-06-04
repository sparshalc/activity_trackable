FactoryBot.define do
  factory :company do
    name { "Company #{SecureRandom.hex(4)}" }

    trait :with_settings do
      after(:create) do |company|
        company.company_setting || create(:company_setting, company: company)
      end
    end
  end
end
