require 'rails_helper'

RSpec.describe "Article publishing", type: :request do
  let_it_be(:admin) { create(:user, :admin) }
  let(:tag) { Tag.find_or_create_by!(name: 'test-tag') }

  it "sets published_at when an admin creates a published article and guest can view it" do
    sign_in_as(admin)

    post dashboard_articles_url, params: { article: { title: "Publish Test", content: "Content", is_published: true, tag_ids: [tag.id], image: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "test_image.jpg"), "image/jpeg") } }

    expect(response).to redirect_to(dashboard_article_url(Article.last))

    article = Article.last
    expect(article.is_published).to be true
    expect(article.published_at).not_to be_nil

    sign_out
    get article_url(article)
    expect(response).to be_successful
  end

  it "clears published_at when an admin unpublishes an article and guest can no longer view it" do
    article = create(:article, :published, user: admin)

    get article_url(article)
    expect(response).to be_successful

    sign_in_as(admin)
    patch dashboard_article_url(article), params: { article: { is_published: false } }
    expect(response).to redirect_to(dashboard_article_url(article))

    article.reload
    expect(article.is_published).to be false
    expect(article.published_at).to be_nil

    sign_out
    get article_url(article)
    expect(response).to redirect_to(root_path)
  end
end
