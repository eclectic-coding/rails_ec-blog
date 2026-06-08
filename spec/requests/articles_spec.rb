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

    describe "SEO meta tags" do
      let(:article) { create(:article, :published, title: "My Rails Article") }

      it "sets title from article" do
        get article_url(article)
        expect(response.body).to match(/<title>Eclectic Coding \| My Rails Article/)
      end

      it "includes meta description" do
        get article_url(article)
        expect(response.body).to include('name="description"')
      end

      it "sets og:type to article" do
        get article_url(article)
        expect(response.body).to include('property="og:type"')
          .and include('content="article"')
      end

      it "sets canonical to article URL" do
        get article_url(article)
        expect(response.body).to include('rel="canonical"')
          .and include(article_url(article))
      end

      it "includes twitter:card" do
        get article_url(article)
        expect(response.body).to include('name="twitter:card"')
          .and include('summary_large_image')
      end

      it "includes og:image" do
        get article_url(article)
        expect(response.body).to include('property="og:image"')
      end

      it "includes JSON-LD BlogPosting" do
        get article_url(article)
        expect(response.body).to include('application/ld+json')
          .and include('"@type":"BlogPosting"')
          .and include('"headline":"My Rails Article"')
      end

      it "escapes dangerous content in JSON-LD" do
        danger = create(:article, :published, title: 'XSS </script><script>alert(1)</script>')
        get article_url(danger)
        expect(response.body).not_to include("</script><script>alert(1)")
      end
    end

    describe "SEO meta tags for articles index" do
      it "sets articles index title" do
        get articles_url
        expect(response.body).to match(/<title>Eclectic Coding \| Articles/)
      end

      it "includes canonical for articles index" do
        get articles_url
        expect(response.body).to include('rel="canonical"')
          .and include(articles_url)
      end
    end
  end
end
