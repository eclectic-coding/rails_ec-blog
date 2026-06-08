require "rails_helper"

RSpec.describe "Statics", type: :request do
  before do
    allow(RubygemsService).to receive(:gems).and_return([])
  end

  describe "GET /home" do
    it "returns http success" do
      get "/static/home"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /" do
    it "returns http success" do
      get "/"
      expect(response).to have_http_status(:success)
    end

    it "includes meta description on home page" do
      get root_url
      expect(response.body).to include('name="description"')
    end

    it "sets canonical to root URL" do
      get root_url
      expect(response.body).to include('rel="canonical"')
        .and include(root_url)
    end

    it "calls RubygemsService" do
      expect(RubygemsService).to receive(:gems).and_return([])
      get "/"
    end

    context "when gems are returned" do
      let(:gems) do
        [{ "name" => "safe_memoize", "version" => "1.7.0", "downloads" => 2890,
           "info" => "A memoization library.", "project_uri" => "https://rubygems.org/gems/safe_memoize",
           "homepage_uri" => "https://github.com/eclectic-coding/safe_memoize" }]
      end

      before { allow(RubygemsService).to receive(:gems).and_return(gems) }

      it "displays the gem name" do
        get "/"
        expect(response.body).to include("safe_memoize")
      end

      it "displays the version" do
        get "/"
        expect(response.body).to include("v1.7.0")
      end
    end
  end
end
