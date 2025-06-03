FactoryBot.define do
  factory :company_setting do
    company { nil }
    activity_tracking { false }
    activity_retention_days { 1 }
  end
end
