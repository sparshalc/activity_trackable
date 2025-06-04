FactoryBot.define do
  factory :recognition do
    association :company
    points { rand(1..20) }
    message { "Great work on the project! Your dedication and attention to detail really made a difference." }
    category { Recognition::CATEGORIES.sample }
    status { :pending }

    transient do
      giver_user { nil }
      recipient_user { nil }
    end

    after(:build) do |recognition, evaluator|
      if evaluator.giver_user
        recognition.giver = evaluator.giver_user
      else
        recognition.giver = create(:user)
      end

      if evaluator.recipient_user
        recognition.recipient = evaluator.recipient_user
      else
        recognition.recipient = create(:user)
      end

      # Ensure both users are in the same company
      recognition.company.add_user(recognition.giver) unless recognition.giver.companies.include?(recognition.company)
      recognition.company.add_user(recognition.recipient) unless recognition.recipient.companies.include?(recognition.company)
    end

    trait :approved do
      status { :approved }
    end

    trait :rejected do
      status { :rejected }
    end

    trait :teamwork do
      category { "teamwork" }
      message { "Excellent collaboration with the team on this project!" }
      points { 10 }
    end

    trait :innovation do
      category { "innovation" }
      message { "Your creative solution saved us hours of work!" }
      points { 15 }
    end

    trait :leadership do
      category { "leadership" }
      message { "Great leadership during the project crisis!" }
      points { 20 }
    end

    trait :customer_service do
      category { "customer_service" }
      message { "Outstanding customer service that resulted in a happy client!" }
      points { 12 }
    end

    trait :going_above_beyond do
      category { "going_above_beyond" }
      message { "Going above and beyond to help the team succeed!" }
      points { 18 }
    end

    trait :high_points do
      points { 20 }
    end

    trait :low_points do
      points { 1 }
    end

    trait :recent do
      created_at { 1.day.ago }
    end

    trait :old do
      created_at { 1.month.ago }
    end
  end
end
