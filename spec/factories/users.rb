# Factory for User
FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password1234" }

    trait :admin do
      admin { true }
    end
  end
end
