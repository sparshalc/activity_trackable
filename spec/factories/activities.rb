FactoryBot.define do
  factory :activity do
    association :user
    association :company
    association :trackable, factory: :user
    action { Activity::ACTIONS.values.sample }
    occurred_at { Time.current }
    metadata { {} }

    trait :login do
      action { "login" }
      metadata do
        {
          ip_address: "192.168.1.1",
          user_agent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
          login_method: "returning"
        }
      end
    end

    trait :logout do
      action { "logout" }
      metadata do
        {
          ip_address: "192.168.1.1",
          session_duration: 3600
        }
      end
    end

    trait :profile_update do
      action { "profile_update" }
      metadata do
        {
          fields_changed: [ "full_name", "email" ]
        }
      end
    end

    trait :recognition_given do
      action { "give_recognition" }
      association :trackable, factory: :recognition
      metadata do
        {
          recognition_id: trackable&.id,
          recipient_name: "John Doe",
          points_given: 10,
          category: "teamwork"
        }
      end
    end

    trait :recognition_received do
      action { "receive_recognition" }
      association :trackable, factory: :recognition
      metadata do
        {
          recognition_id: trackable&.id,
          giver_name: "Jane Smith",
          points_received: 10,
          category: "teamwork"
        }
      end
    end

    trait :company_joined do
      action { "company_joined" }
      association :trackable, factory: :company_user
      metadata do
        {
          company_name: "Test Company",
          initial_role: "employee"
        }
      end
    end

    trait :role_assigned do
      action { "role_assigned" }
      association :trackable, factory: :company_user_role
      metadata do
        {
          role_name: "admin",
          assigned_at: Time.current
        }
      end
    end

    trait :user_discarded do
      action { "user_discarded" }
      metadata do
        {
          reason: "Inactive user",
          discarded_by_name: "Admin User",
          discarded_at: Time.current.iso8601
        }
      end
    end

    trait :recent do
      occurred_at { 1.hour.ago }
    end

    trait :old do
      occurred_at { 1.month.ago }
    end
  end
end
