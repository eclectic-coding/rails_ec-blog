require 'rails_helper'

RSpec.describe "/articles", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      create(:article, :published)
      get articles_url
      expect(response).to be_successful
    end

    it "shows only published articles to unauthenticated users" do
      create(:article, :published, title: "Published")
      create(:article, title: "Draft")

      get articles_url
      expect(response).to be_successful
      expect(response.body).to include("Published")
      expect(response.body).not_to include("Draft")
    end

    it "shows all articles to admin users" do
      create(:article, :published, title: "Published")
      create(:article, title: "Draft")

      sign_in_as(create(:user, :admin))
      get articles_url
      expect(response).to be_successful
      expect(response.body).to include("Published")
      expect(response.body).to include("Draft")
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      article = create(:article, :published)
      get article_url(article)
      expect(response).to be_successful
    end

    it "blocks unpublished articles for non-admins" do
      draft = create(:article, title: "DraftShow")
      get article_url(draft)
      expect(response).to redirect_to(root_path)
    end

    it "allows admins to view unpublished articles" do
      draft = create(:article, title: "DraftShow")
      sign_in_as(create(:user, :admin))
      get article_url(draft)
      expect(response).to be_successful
    end
  end
end
