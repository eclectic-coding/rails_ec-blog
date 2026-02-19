require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  describe 'GET /tags' do
    it 'returns a successful response' do
      get tags_path
      expect(response).to be_successful
    end

    it 'displays all tags ordered by name' do
      tag_b = create(:tag, name: 'rails')
      tag_a = create(:tag, name: 'javascript')
      tag_c = create(:tag, name: 'ruby')

      get tags_path

      expect(response.body).to include('javascript', 'rails', 'ruby')
    end
  end

  describe 'GET /tags/:id' do
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
  end
end

