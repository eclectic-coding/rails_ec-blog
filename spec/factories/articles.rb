# == Schema Information
#
# Table name: articles
#
#  id             :integer          not null, primary key
#  title          :string
#  content        :text
#  published_date :date
#  is_published   :boolean          default(FALSE)
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  published_time :time
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#

FactoryBot.define do
  factory :article do
    title { "MyString" }
    content { "MyText" }
    published_date { Date.current }
    published_time { nil }
    is_published { false }
    user { nil }
  end
end
