# Factory for Article
FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Test Article #{n}" }
    content { "Sample content for testing." }
    association :user

    trait :published do
      is_published { true }
      published_at { Time.current }
    end
  end
end
