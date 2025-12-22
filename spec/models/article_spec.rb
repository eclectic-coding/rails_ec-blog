require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user) { create(:user) }

  describe 'published_at autoset behavior' do
    it 'sets published_at when publishing if it was blank' do
      article = create(:article, user: user, is_published: false, published_at: nil)
      expect(article.published_at).to be_nil

      article.update!(is_published: true)

      expect(article.published_at).not_to be_nil
      expect(article.published_at).to be_a(ActiveSupport::TimeWithZone)
    end

    it 'does not overwrite an existing published_at when publishing' do
      existing_time = 2.days.ago
      article = create(:article, user: user, is_published: true, published_at: existing_time)

      article.update!(is_published: true)

      expect(article.published_at.to_i).to eq(existing_time.to_i)
    end

    it 'clears published_at when unpublishing' do
      article = create(:article, user: user, is_published: true, published_at: Time.current)
      expect(article.published_at).not_to be_nil

      article.update!(is_published: false)

      expect(article.published_at).to be_nil
    end
  end
end
