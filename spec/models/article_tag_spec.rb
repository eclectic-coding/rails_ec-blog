# == Schema Information
#
# Table name: article_tags
#
#  id         :integer          not null, primary key
#  article_id :integer          not null
#  tag_id     :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_article_tags_on_article_id             (article_id)
#  index_article_tags_on_article_id_and_tag_id  (article_id,tag_id) UNIQUE
#  index_article_tags_on_tag_id                 (tag_id)
#

require 'rails_helper'

RSpec.describe ArticleTag, type: :model do
  describe 'associations' do
    it 'belongs to article' do
      article_tag = create(:article_tag)
      expect(article_tag.article).to be_present
      expect(article_tag.article).to be_a(Article)
    end

    it 'belongs to tag' do
      article_tag = create(:article_tag)
      expect(article_tag.tag).to be_present
      expect(article_tag.tag).to be_a(Tag)
    end
  end

  describe 'validations' do
    it 'validates uniqueness of article_id scoped to tag_id' do
      article = create(:article)
      tag = create(:tag)
      create(:article_tag, article: article, tag: tag)

      duplicate = ArticleTag.new(article: article, tag: tag)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:article_id]).to include('has already been taken')
    end

    it 'allows same tag on different articles' do
      tag = create(:tag)
      article1 = create(:article)
      article2 = create(:article)

      create(:article_tag, article: article1, tag: tag)
      second = ArticleTag.new(article: article2, tag: tag)

      expect(second).to be_valid
    end
  end
end
