FactoryBot.define do
  factory :recognition do
    giver { nil }
    recipient { nil }
    company { nil }
    points { 1 }
    message { "MyText" }
    category { "MyString" }
    status { 1 }
  end
end
