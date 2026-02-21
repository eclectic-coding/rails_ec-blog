# == Schema Information
#
# Table name: articles
#
#  id             :integer          not null, primary key
#  title          :string
#  content        :text
#  is_published   :boolean          default(FALSE)
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  published_date :date
#  published_time :time
#  published_at   :datetime
#
# Indexes
#
#  index_articles_on_published_at  (published_at)
#  index_articles_on_user_id       (user_id)
#

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

      # Ensure at least one tag is present for validation
      if article.tags.empty?
        article.tags << FactoryBot.build(:tag)
      end
    end

    trait :published do
      is_published { true }
      published_at { Time.current }
    end
  end
end
