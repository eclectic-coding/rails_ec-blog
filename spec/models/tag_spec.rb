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

    it 'converts hyphens to spaces' do
      tag = Tag.create(name: 'rest-api')
      expect(tag.name).to eq('rest api')
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

  describe '#to_param' do
    it 'returns the tag name for use in URLs' do
      tag = create(:tag, name: 'ruby')
      expect(tag.to_param).to eq('ruby')
    end

    it 'uses hyphens instead of spaces for multi-word tags' do
      tag = create(:tag, name: 'web development')
      expect(tag.to_param).to eq('web-development')
    end
  end

  describe '#display_name' do
    it 'capitalizes regular words' do
      tag = create(:tag, name: 'ruby')
      expect(tag.display_name).to eq('Ruby')
    end

    it 'displays abbreviations in all caps' do
      tag = create(:tag, name: 'css')
      expect(tag.display_name).to eq('CSS')
    end

    it 'handles mixed regular words and abbreviations' do
      tag = create(:tag, name: 'css framework')
      expect(tag.display_name).to eq('CSS Framework')
    end

    it 'handles multiple words' do
      tag = create(:tag, name: 'web development')
      expect(tag.display_name).to eq('Web Development')
    end

    it 'handles multi-word abbreviations' do
      tag = create(:tag, name: 'rest api')
      expect(tag.display_name).to eq('REST API')
    end
  end

  describe '.find_by_param' do
    it 'finds tag by exact name' do
      tag = create(:tag, name: 'ruby')
      expect(Tag.find_by_param('ruby')).to eq(tag)
    end

    it 'finds tag by hyphenated slug' do
      tag = create(:tag, name: 'web development')
      expect(Tag.find_by_param('web-development')).to eq(tag)
    end

    it 'returns nil for non-existent tag' do
      expect(Tag.find_by_param('nonexistent')).to be_nil
    end
  end
end
