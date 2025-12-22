require 'rails_helper'

RSpec.describe "Article publishing", type: :request do
  let(:admin) { create(:user) }

  before do
    # ensure the shared auth helpers are available
    # sign_in_as is provided by spec/support/admin_login_helper.rb
  end

  it "sets published_at when an admin creates a published article and guest can view it" do
    sign_in_as(admin)

    post articles_url, params: { article: { title: "Publish Test", content: "Content", is_published: true, user_id: admin.id } }

    expect(response).to redirect_to(article_url(Article.last))

    article = Article.last
    expect(article.is_published).to be true
    expect(article.published_at).not_to be_nil

    # sign out and verify guest can view the published article
    sign_out
    get article_url(article)
    expect(response).to be_successful
  end

  it "clears published_at when an admin unpublishes an article and guest can no longer view it" do
    # create a published article
    article = create(:article, is_published: true, published_at: 1.day.ago, user: admin)

    # confirm guest can view it
    get article_url(article)
    expect(response).to be_successful

    # admin unpublishes
    sign_in_as(admin)
    patch article_url(article), params: { article: { is_published: false } }
    expect(response).to redirect_to(article_url(article))

    article.reload
    expect(article.is_published).to be false
    expect(article.published_at).to be_nil

    # sign out and guest should be blocked from viewing
    sign_out
    get article_url(article)
    expect(response).to redirect_to(root_path)
  end
end
