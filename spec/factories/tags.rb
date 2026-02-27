FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "tag#{n}" }

    trait :ruby do
      name { "ruby" }
    end

    trait :rails do
      name { "rails" }
    end

    trait :javascript do
      name { "javascript" }
    end
  end
end
