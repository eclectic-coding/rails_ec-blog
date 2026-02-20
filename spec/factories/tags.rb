# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#

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
