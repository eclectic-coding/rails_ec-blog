# == Schema Information
#
# Table name: articles
#
#  id           :integer          not null, primary key
#  title        :string
#  content      :text
#  published_at :datetime
#  is_published :boolean          default(FALSE)
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#

FactoryBot.define do
  factory :article do
    title { "MyString" }
    content { "MyText" }
    published_at { "2025-12-22 11:54:21" }
    is_published { false }
    user { nil }
  end
end
