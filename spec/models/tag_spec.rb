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

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'associations' do
    it 'has many article_tags' do
      tag = create(:tag)
      article = create(:article, tags: [tag])

      expect(tag.article_tags.count).to eq(1)
      expect(tag.article_tags.first.article).to eq(article)
    end

    it 'has many articles through article_tags' do
      tag = create(:tag)
      article1 = create(:article, tags: [tag])
      article2 = create(:article, tags: [tag])

      expect(tag.articles).to include(article1, article2)
    end

    it 'destroys article_tags when destroyed' do
      tag = create(:tag)
      create(:article, tags: [tag])

      expect { tag.destroy }.to change { ArticleTag.count }.by(-1)
    end
  end

  describe 'validations' do
    it 'requires a name' do
      tag = Tag.new(name: nil)
      expect(tag).not_to be_valid
      expect(tag.errors[:name]).to include("can't be blank")
    end

    it 'requires unique name' do
      create(:tag, name: 'ruby')
      duplicate = Tag.new(name: 'ruby')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include('has already been taken')
    end

    it 'validates uniqueness case-insensitively' do
      create(:tag, name: 'ruby')
      duplicate = Tag.new(name: 'RUBY')

      expect(duplicate).not_to be_valid
    end
  end

  describe 'callbacks' do
    it 'normalizes name before save' do
      tag = Tag.create(name: '  Ruby  ')
      expect(tag.name).to eq('ruby')
    end

    it 'converts name to lowercase' do
      tag = Tag.create(name: 'JavaScript')
      expect(tag.name).to eq('javascript')
    end
  end

  describe '.ordered' do
    it 'returns tags in alphabetical order' do
      tag_c = create(:tag, name: 'css')
      tag_a = create(:tag, name: 'rails')
      tag_b = create(:tag, name: 'javascript')

      expect(Tag.ordered.to_a).to eq([tag_c, tag_b, tag_a])
    end
  end
end
