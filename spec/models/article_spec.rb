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

require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user) { create(:user) }

  describe 'published_at autoset behavior' do
    it 'sets published_at when publishing if it was blank' do
      article = create(:article, user: user, is_published: false, published_at: nil)
      expect(article.published_at).to be_nil

      article.update!(is_published: true)

      expect(article.published_at).not_to be_nil
      expect(article.published_at).to be_a(Date)
    end

    it 'does not overwrite an existing published_at when publishing' do
      existing_date = 2.days.ago.to_date
      article = create(:article, user: user, is_published: true, published_at: existing_date)

      article.update!(is_published: true)

      expect(article.published_at).to eq(existing_date)
    end

    it 'clears published_at when unpublishing' do
      article = create(:article, user: user, is_published: true, published_at: Date.current)
      expect(article.published_at).not_to be_nil

      article.update!(is_published: false)

      expect(article.published_at).to be_nil
    end
  end
end
