require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    allow_unauthenticated_access only: %i[test auth_check]

    def test
      render plain: after_authentication_url
    end

    def auth_check
      render plain: authenticated?.to_s
    end
  end

  before do
    routes.draw do
      get "test" => "anonymous#test"
      get "auth_check" => "anonymous#auth_check"
    end
  end

  describe "#authenticated?" do
    it "returns false when no session cookie is present" do
      get :auth_check
      expect(response.body).to eq("false")
    end

    it "returns true when a valid session cookie is present" do
      user = create(:user)
      session_record = user.sessions.create!
      cookies.signed[:session_id] = session_record.id
      get :auth_check
      expect(response.body).to eq("true")
    end
  end

  describe "#after_authentication_url" do
    it "returns root_url when no redirect is stored in session" do
      get :test
      expect(response.body).to eq(root_url)
    end

    it "returns the stored URL and clears it from the session" do
      session[:return_to_after_authenticating] = "http://test.host/some/path"

      get :test

      expect(response.body).to eq("http://test.host/some/path")
      expect(session[:return_to_after_authenticating]).to be_nil
    end
  end
end
