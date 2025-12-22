require 'rails_helper'

RSpec.describe "Article owner management", type: :request do
  let(:admin) { create(:user) }
  let(:non_admin) { create(:user, admin: false) }
  let(:original_owner) { create(:user) }
  let(:article) { create(:article, user: original_owner) }

  describe "PATCH /articles/:id/set_owner" do
    context "when signed in as admin" do
      before { sign_in_as(admin) }

      it "changes the article owner and redirects to the article" do
        new_owner = create(:user, admin: false)

        patch set_owner_article_path(article), params: { article: { user_id: new_owner.id } }

        expect(response).to redirect_to(article_url(article))
        article.reload
        expect(article.user_id).to eq(new_owner.id)
      end
    end

    context "when signed in as non-admin" do
      before { sign_in_as(non_admin) }

      it "does not change the owner and redirects to root" do
        new_owner = create(:user, admin: false)

        patch set_owner_article_path(article), params: { article: { user_id: new_owner.id } }

        expect(response).to redirect_to(root_path)
        article.reload
        expect(article.user_id).to eq(original_owner.id)
      end
    end

    context "when unauthenticated" do
      it "redirects to sign in" do
        new_owner = create(:user)

        patch set_owner_article_path(article), params: { article: { user_id: new_owner.id } }

        expect(response).to redirect_to(new_session_path)
        article.reload
        expect(article.user_id).to eq(original_owner.id)
      end
    end
  end
end

