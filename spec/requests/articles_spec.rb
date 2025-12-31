require 'rails_helper'

RSpec.describe "/articles", type: :request do
  let(:valid_attributes) {
    # Explicit attributes (avoid association keys in params)
    {
      title: "MyString",
      content: "MyText",
      published_at: Time.current.to_s,
      is_published: true,
      # include a small uploaded image so controller create/update requests pass the model validation
      image: Rack::Test::UploadedFile.new(Rails.root.join("spec", "fixtures", "files", "test_image.jpg"), "image/jpeg")
    }
  }

  let(:invalid_attributes) {
    # Missing required title (Article validates presence of title)
    { title: nil, content: "MyText", published_at: Time.current.to_s }
  }

  describe "GET /index" do
    it "renders a successful response" do
      create(:article, **valid_attributes.merge(user: create(:user)))
      get articles_url
      expect(response).to be_successful
    end

    it "shows only published articles to unauthenticated users" do
      create(:article, title: "Published", is_published: true, user: create(:user))
      create(:article, title: "Draft", is_published: false, user: create(:user))

      get articles_url
      expect(response).to be_successful
      expect(response.body).to include("Published")
      expect(response.body).not_to include("Draft")
    end

    it "shows all articles to admin users" do
      create(:article, title: "Published", is_published: true, user: create(:user))
      create(:article, title: "Draft", is_published: false, user: create(:user))

      sign_in_as(create(:user, :admin))
      get articles_url
      expect(response).to be_successful
      expect(response.body).to include("Published")
      expect(response.body).to include("Draft")
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      article = create(:article, **valid_attributes.merge(user: create(:user)))
      get article_url(article)
      expect(response).to be_successful
    end

    it "blocks unpublished articles for non-admins" do
      draft = create(:article, title: "DraftShow", is_published: false, user: create(:user))
      get article_url(draft)
      expect(response).to redirect_to(root_path)
    end

    it "allows admins to view unpublished articles" do
      draft = create(:article, title: "DraftShow", is_published: false, user: create(:user))
      sign_in_as(create(:user, :admin))
      get article_url(draft)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "redirects to sign in for unauthenticated users" do
      get new_article_url
      expect(response).to redirect_to(root_path)
    end

    it "renders a successful response for authenticated admin users" do
      sign_in_as(create(:user, :admin))
      get new_article_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      article = create(:article, **valid_attributes.merge(user: create(:user)))
      sign_in_as(create(:user, :admin))
      get edit_article_url(article)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Article" do
        user = create(:user, :admin)
        sign_in_as(user)

        expect {
          post articles_url, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)
      end

      it "redirects to the created article" do
        user = create(:user, :admin)
        sign_in_as(user)
        post articles_url, params: { article: valid_attributes }
        expect(response).to redirect_to(article_url(Article.last))
      end

      it "uses provided article[user_id] when current_user is not present" do
        # Ensure no session is active
        sign_out

        target_user = create(:user)

        # Bypass admin-only before_action so we can exercise the branch
        allow_any_instance_of(ArticlesController).to receive(:admin_only!).and_return(nil)

        expect {
          post articles_url, params: { article: valid_attributes.merge(user_id: target_user.id) }
        }.to change(Article, :count).by(1)

        expect(Article.last.user_id).to eq(target_user.id)
      end

      it "assigns the first user when no current_user and no user_id param" do
        # Ensure no session is active
        sign_out

        first_user = create(:user)

        allow_any_instance_of(ArticlesController).to receive(:admin_only!).and_return(nil)

        expect {
          post articles_url, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)

        expect(Article.last.user_id).to eq(User.first.id)
        expect(Article.last.user_id).to eq(first_user.id)
      end

      it "assigns current_user as the article's user when signed in" do
        user = create(:user, :admin)
        sign_in_as(user)

        expect {
          post articles_url, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)

        expect(Article.last.user_id).to eq(user.id)
      end

      it "uses controller current_user when respond_to?(:current_user) is true" do
        user = create(:user)

        # Ensure no session is active so fallback doesn't accidentally pick up User.first
        sign_out

        # Bypass admin authorization
        allow_any_instance_of(ArticlesController).to receive(:admin_only!).and_return(nil)

        # Make the controller report it responds to :current_user and return our user
        allow_any_instance_of(ArticlesController).to receive(:respond_to?).and_wrap_original do |m, *args|
          # return true for respond_to?(:current_user) (symbol or string), otherwise fall back to original
          if args.first.to_s == 'current_user'
            true
          else
            m.call(*args)
          end
        end

        allow_any_instance_of(ArticlesController).to receive(:current_user).and_return(user)

        expect {
          post articles_url, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)

        expect(Article.last.user_id).to eq(user.id)
      end
    end

    context "with invalid parameters" do
      it "does not create a new Article" do
        user = create(:user, :admin)
        sign_in_as(user)
        expect {
          post articles_url, params: { article: invalid_attributes }
        }.to change(Article, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)'" do
        user = create(:user, :admin)
        sign_in_as(user)
        post articles_url, params: { article: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        {
          title: "Updated Title",
          content: "Updated content",
          published_at: Time.current,
          is_published: true
        }
      }

      it "updates the requested article" do
        article = create(:article, **valid_attributes.merge(user: create(:user)))
        sign_in_as(create(:user, :admin))
        patch article_url(article), params: { article: new_attributes }
        article.reload
        expect(article.title).to eq(new_attributes[:title])
        expect(article.content).to eq(new_attributes[:content])
      end

      it "redirects to the article" do
        article = create(:article, **valid_attributes.merge(user: create(:user)))
        sign_in_as(create(:user, :admin))
        patch article_url(article), params: { article: new_attributes }
        article.reload
        expect(response).to redirect_to(article_url(article))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        article = create(:article, **valid_attributes.merge(user: create(:user)))
        sign_in_as(create(:user, :admin))
        patch article_url(article), params: { article: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested article" do
      article = create(:article, **valid_attributes.merge(user: create(:user)))
      sign_in_as(create(:user, :admin))
      expect {
        delete article_url(article)
      }.to change(Article, :count).by(-1)
    end

    it "redirects to the articles list" do
      article = create(:article, **valid_attributes.merge(user: create(:user)))
      sign_in_as(create(:user, :admin))
      delete article_url(article)
      expect(response).to redirect_to(articles_url)
    end
  end
end
