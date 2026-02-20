require 'rails_helper'

RSpec.describe "/tags", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    { name: "ruby on rails" }
  end

  let(:invalid_attributes) do
    { name: "" }
  end

  describe "POST /create" do
    context "when authenticated" do
      before do
        sign_in_as(user)
      end

      context "with valid parameters" do
        it "creates a new Tag" do
          expect {
            post tags_url, params: { tag: valid_attributes }, as: :json
          }.to change(Tag, :count).by(1)
        end

        it "returns a created status" do
          post tags_url, params: { tag: valid_attributes }, as: :json
          expect(response).to have_http_status(:created)
        end

        it "returns the tag id and display_name" do
          post tags_url, params: { tag: valid_attributes }, as: :json
          json_response = JSON.parse(response.body)

          expect(json_response).to have_key("id")
          expect(json_response).to have_key("name")
          expect(json_response["name"]).to eq("Ruby On Rails") # display_name capitalizes
        end

        it "normalizes the tag name" do
          post tags_url, params: { tag: { name: "  RUBY   ON   RAILS  " } }, as: :json
          json_response = JSON.parse(response.body)

          tag = Tag.find(json_response["id"])
          expect(tag.name).to eq("ruby on rails") # normalized: lowercase, single spaces
        end

        it "handles hyphenated names correctly" do
          post tags_url, params: { tag: { name: "test-tag-name" } }, as: :json
          json_response = JSON.parse(response.body)

          tag = Tag.find(json_response["id"])
          expect(tag.name).to eq("test tag name") # hyphens converted to spaces
        end

        it "capitalizes abbreviations in display_name" do
          post tags_url, params: { tag: { name: "html css" } }, as: :json
          json_response = JSON.parse(response.body)

          expect(json_response["name"]).to eq("HTML CSS") # abbreviations in all caps
        end
      end

      context "with invalid parameters" do
        it "does not create a new Tag with blank name" do
          expect {
            post tags_url, params: { tag: invalid_attributes }, as: :json
          }.to change(Tag, :count).by(0)
        end

        it "returns unprocessable_content status for blank name" do
          post tags_url, params: { tag: invalid_attributes }, as: :json
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns error messages for blank name" do
          post tags_url, params: { tag: invalid_attributes }, as: :json
          json_response = JSON.parse(response.body)

          expect(json_response).to have_key("errors")
          expect(json_response["errors"]).to be_an(Array)
          expect(json_response["errors"]).to include("Name can't be blank")
        end
      end

      context "with duplicate tag name" do
        before do
          create(:tag, name: "ruby")
        end

        it "does not create a duplicate Tag" do
          expect {
            post tags_url, params: { tag: { name: "ruby" } }, as: :json
          }.to change(Tag, :count).by(0)
        end

        it "returns unprocessable_content status for duplicate" do
          post tags_url, params: { tag: { name: "ruby" } }, as: :json
          expect(response).to have_http_status(:unprocessable_content)
        end

        it "returns uniqueness error message" do
          post tags_url, params: { tag: { name: "ruby" } }, as: :json
          json_response = JSON.parse(response.body)

          expect(json_response["errors"]).to include("Name has already been taken")
        end

        it "prevents duplicates case-insensitively" do
          expect {
            post tags_url, params: { tag: { name: "RUBY" } }, as: :json
          }.to change(Tag, :count).by(0)

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when not authenticated" do
      it "requires authentication to create tags" do
        post tags_url, params: { tag: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not create a tag without authentication" do
        expect {
          post tags_url, params: { tag: valid_attributes }, as: :json
        }.to change(Tag, :count).by(0)
      end
    end

    context "with non-JSON requests" do
      before do
        sign_in_as(user)
      end

      it "only responds to JSON format" do
        post tags_url, params: { tag: valid_attributes }
        # Should not render JSON for HTML requests
        expect(response).to have_http_status(:not_acceptable)
      end
    end
  end
end
