require "rails_helper"

RSpec.describe "Dashboard::Projects::RubygemsImport", type: :request do
  let(:admin) { create(:user, :admin) }

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

  context "when unauthenticated" do
    it "returns 404 (route constraint)" do
      post dashboard_projects_rubygems_import_path
      expect(response).to have_http_status(:not_found)
    end
  end

  context "when authenticated as admin" do
    before do
      sign_in_as(admin)
      allow(RubygemsService).to receive(:gems).and_return(gem_payload)
    end

    it "creates projects for gems not already in the database" do
      expect {
        post dashboard_projects_rubygems_import_path
      }.to change(Project, :count).by(2)
      expect(response).to redirect_to(dashboard_projects_path)
    end

    it "sets project attributes from gem data" do
      post dashboard_projects_rubygems_import_path
      project = Project.find_by(rubygem_name: "safe_memoize")
      expect(project.version).to eq("1.7.0")
      expect(project.url).to eq("https://rubygems.org/gems/safe_memoize")
      expect(project.source_url).to eq("https://github.com/eclectic-coding/safe_memoize")
      expect(project.project_type).to eq("rubygem")
    end

    it "skips gems that already exist" do
      create(:project, :rubygem, rubygem_name: "safe_memoize")
      expect {
        post dashboard_projects_rubygems_import_path
      }.to change(Project, :count).by(1)
    end

    it "omits source_url when homepage_uri is nil" do
      post dashboard_projects_rubygems_import_path
      project = Project.find_by(rubygem_name: "another_gem")
      expect(project.source_url).to be_nil
    end

    it "omits source_url when homepage_uri is not http/https" do
      gem_payload.first["homepage_uri"] = "ftp://not-safe.com"
      post dashboard_projects_rubygems_import_path
      expect(Project.find_by(rubygem_name: "safe_memoize").source_url).to be_nil
    end

    it "redirects with an alert when no gems are returned" do
      allow(RubygemsService).to receive(:gems).and_return([])
      post dashboard_projects_rubygems_import_path
      expect(response).to redirect_to(dashboard_projects_path)
      expect(flash[:alert]).to be_present
    end

    it "includes import counts in the flash notice" do
      create(:project, :rubygem, rubygem_name: "safe_memoize")
      post dashboard_projects_rubygems_import_path
      expect(flash[:notice]).to match(/1 gem imported/)
      expect(flash[:notice]).to match(/1 already existed/)
    end
  end
end
