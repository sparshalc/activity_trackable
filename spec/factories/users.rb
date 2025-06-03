FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }

    trait :with_tracking_data do
      sign_in_count { 5 }
      current_sign_in_at { 1.hour.ago }
      last_sign_in_at { 1.day.ago }
      current_sign_in_ip { '192.168.1.1' }
      last_sign_in_ip { '192.168.1.2' }
    end
  end
end
