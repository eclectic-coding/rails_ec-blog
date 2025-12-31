# Factory for Article
FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Test Article #{n}" }
    content { "Sample content for testing." }
    association :user

    # Attach a small in-memory image so model validations that require an image pass in tests
    after(:build) do |article|
      unless article.image.attached?
        # Use a small in-memory blob to avoid relying on fixture files
        article.image.attach(io: StringIO.new("x" * 1024), filename: "sample.png", content_type: "image/png")
      end
    end

    trait :published do
      is_published { true }
      published_at { Time.current }
    end
  end
end
