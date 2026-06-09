require "rails_helper"

RSpec.describe "Dashboard::Projects", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project) }

  context "when unauthenticated" do
    it "returns 404 for all actions (route constraint)" do
      get dashboard_projects_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/projects" do
      it "returns 200" do
        project
        get dashboard_projects_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/projects/:id" do
      it "returns 200" do
        get dashboard_project_path(project)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/projects/new" do
      it "returns 200" do
        get new_dashboard_project_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "GET /admin/projects/:id/edit" do
      it "returns 200" do
        get edit_dashboard_project_path(project)
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/projects" do
      let(:valid_params) { { project: { name: "My Gem", url: "https://example.com", project_type: "rubygem" } } }

      it "creates a project and redirects to show" do
        expect {
          post dashboard_projects_path, params: valid_params
        }.to change(Project, :count).by(1)
        expect(response).to redirect_to(dashboard_project_path(Project.last))
      end

      it "renders new with 422 on missing name" do
        post dashboard_projects_path, params: { project: { name: "", url: "https://example.com", project_type: "github" } }
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "renders new with 422 on invalid project_type" do
        post dashboard_projects_path, params: { project: { name: "X", url: "https://example.com", project_type: "invalid" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "PATCH /admin/projects/:id" do
      it "updates the project and redirects to show" do
        patch dashboard_project_path(project), params: { project: { name: "Updated Name" } }
        expect(project.reload.name).to eq("Updated Name")
        expect(response).to redirect_to(dashboard_project_path(project))
      end

      it "renders edit with 422 on invalid params" do
        patch dashboard_project_path(project), params: { project: { name: "" } }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    describe "DELETE /admin/projects/:id" do
      it "destroys the project and redirects to index" do
        project
        expect {
          delete dashboard_project_path(project)
        }.to change(Project, :count).by(-1)
        expect(response).to redirect_to(dashboard_projects_path)
      end
    end

    describe "POST /admin/projects/import_rubygems" do
      let(:gem_payload) do
        [
          {
            "name"         => "safe_memoize",
            "version"      => "1.7.0",
            "info"         => "A memoization library.",
            "project_uri"  => "https://rubygems.org/gems/safe_memoize",
            "homepage_uri" => "https://github.com/eclectic-coding/safe_memoize"
          },
          {
            "name"         => "another_gem",
            "version"      => "0.1.0",
            "info"         => "Another gem.",
            "project_uri"  => "https://rubygems.org/gems/another_gem",
            "homepage_uri" => nil
          }
        ]
      end

      before { allow(RubygemsService).to receive(:gems).and_return(gem_payload) }

      it "creates projects for gems not already in the database" do
        expect {
          post import_rubygems_dashboard_projects_path
        }.to change(Project, :count).by(2)
        expect(response).to redirect_to(dashboard_projects_path)
      end

      it "sets project attributes from gem data" do
        post import_rubygems_dashboard_projects_path
        project = Project.find_by(rubygem_name: "safe_memoize")
        expect(project.version).to eq("1.7.0")
        expect(project.url).to eq("https://rubygems.org/gems/safe_memoize")
        expect(project.source_url).to eq("https://github.com/eclectic-coding/safe_memoize")
        expect(project.project_type).to eq("rubygem")
      end

      it "skips gems that already exist" do
        create(:project, :rubygem, rubygem_name: "safe_memoize")
        expect {
          post import_rubygems_dashboard_projects_path
        }.to change(Project, :count).by(1)
        expect(response).to redirect_to(dashboard_projects_path)
      end

      it "omits source_url when homepage_uri is nil" do
        post import_rubygems_dashboard_projects_path
        project = Project.find_by(rubygem_name: "another_gem")
        expect(project.source_url).to be_nil
      end

      it "omits source_url when homepage_uri is not http/https" do
        gem_payload.first["homepage_uri"] = "ftp://not-safe.com"
        post import_rubygems_dashboard_projects_path
        project = Project.find_by(rubygem_name: "safe_memoize")
        expect(project.source_url).to be_nil
      end

      it "redirects with an alert when no gems are returned" do
        allow(RubygemsService).to receive(:gems).and_return([])
        post import_rubygems_dashboard_projects_path
        expect(response).to redirect_to(dashboard_projects_path)
        expect(flash[:alert]).to be_present
      end

      it "includes import counts in the flash notice" do
        create(:project, :rubygem, rubygem_name: "safe_memoize")
        post import_rubygems_dashboard_projects_path
        expect(flash[:notice]).to match(/1 gem imported/)
        expect(flash[:notice]).to match(/1 already existed/)
      end
    end
  end
end
