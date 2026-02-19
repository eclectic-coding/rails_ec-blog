require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  describe 'GET /tags/:name' do
    let(:tag) { create(:tag, name: 'ruby') }
    let(:user) { create(:user) }
    let!(:article1) { create(:article, :published, tags: [tag], user: user, title: 'Ruby Article 1') }
    let!(:article2) { create(:article, :published, tags: [tag], user: user, title: 'Ruby Article 2') }
    let!(:draft_article) { create(:article, tags: [tag], user: user, title: 'Draft Article') }

    it 'returns a successful response' do
      get tag_path(tag)
      expect(response).to be_successful
    end

    it 'displays the tag name' do
      get tag_path(tag)
      expect(response.body).to include('ruby')
    end

    it 'displays published articles for the tag' do
      get tag_path(tag)
      expect(response.body).to include('Ruby Article 1', 'Ruby Article 2')
    end

    it 'does not show draft articles to non-admin users' do
      get tag_path(tag)
      expect(response.body).not_to include('Draft Article')
    end

    it 'generates URL with tag name instead of ID' do
      expect(tag_path(tag)).to eq('/tags/ruby')
    end

    context 'with multi-word tag names' do
      let(:multi_word_tag) { create(:tag, name: 'web development') }
      let!(:tagged_article) { create(:article, :published, tags: [multi_word_tag], user: user) }

      it 'generates hyphenated URL' do
        expect(tag_path(multi_word_tag)).to eq('/tags/web-development')
      end

      it 'finds tag by hyphenated slug' do
        get '/tags/web-development'
        expect(response).to be_successful
        expect(response.body).to include('Web Development')
      end
    end
  end
end
