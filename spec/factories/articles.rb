# == Schema Information
#
# Table name: articles
#
#  id           :integer          not null, primary key
#  title        :string
#  content      :text
#  is_published :boolean          default(FALSE)
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  published_at :datetime
#
# Indexes
#
#  index_articles_on_published_at  (published_at)
#  index_articles_on_user_id       (user_id)
#

FactoryBot.define do
  factory :article do
    title { "MyString" }
    content { "MyText" }
    published_at { Date.current }
    is_published { false }
    user { nil }
  end
end
