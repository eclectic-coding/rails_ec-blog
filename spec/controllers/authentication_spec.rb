require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    # Allow unauthenticated access so the before_action from the concern doesn't block the test action
    allow_unauthenticated_access only: [:test]

    def test
      # call the private helper and render its value so we can assert on it
      render plain: after_authentication_url
    end
  end

  # Ensure the anonymous controller action has a route for GET /test in the test environment
  before do
    routes.draw { get "test" => "anonymous#test" }
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
