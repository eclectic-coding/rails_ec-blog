require "rails_helper"

RSpec.describe "Projects", type: :request do
  describe "GET /projects" do
    it "returns 200 for unauthenticated visitors" do
      get projects_path
      expect(response).to have_http_status(:ok)
    end

    it "renders featured projects before non-featured" do
      create(:project, name: "Plain Gem", is_featured: false)
      create(:project, name: "Star Gem",  is_featured: true)

      get projects_path

      expect(response.body.index("Star Gem")).to be < response.body.index("Plain Gem")
    end

    it "renders an external link to the project url" do
      create(:project, name: "My Tool", url: "https://example.com/my-tool")

      get projects_path

      expect(response.body).to include('href="https://example.com/my-tool"')
    end

    it "shows the version when present" do
      create(:project, :rubygem, version: "3.2.1")

      get projects_path

      expect(response.body).to include("v3.2.1")
    end

    it "shows a source link when source_url is present" do
      create(:project, source_url: "https://github.com/example/repo")

      get projects_path

      expect(response.body).to include('href="https://github.com/example/repo"')
    end

    it "renders an empty state when there are no projects" do
      get projects_path
      expect(response.body).to include("No projects yet")
    end
  end
end
