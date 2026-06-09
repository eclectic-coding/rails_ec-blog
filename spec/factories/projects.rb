FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Test Project #{n}" }
    url { "https://example.com/project" }
    project_type { "github" }
    is_featured { false }

    trait :rubygem do
      project_type { "rubygem" }
      sequence(:rubygem_name) { |n| "my-gem-#{n}" }
      version { "1.0.0" }
    end

    trait :featured do
      is_featured { true }
    end
  end
end
