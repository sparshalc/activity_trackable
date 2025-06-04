FactoryBot.define do
  factory :company_setting do
    association :company
    activity_tracking { true }
    activity_retention_days { 30 }

    trait :activity_disabled do
      activity_tracking { false }
    end

    trait :short_retention do
      activity_retention_days { 1 }
    end

    trait :long_retention do
      activity_retention_days { 365 }
    end

    trait :minimal_retention do
      activity_retention_days { 1 }
    end

    trait :extended_retention do
      activity_retention_days { 90 }
    end
  end
end
