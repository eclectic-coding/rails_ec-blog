require "rails_helper"

RSpec.describe RubygemsImportService do
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

  describe ".call" do
    context "when RubygemsService returns gems" do
      it "returns gems_found: true" do
        expect(described_class.call.gems_found).to be true
      end

      it "creates a project for each new gem" do
        expect { described_class.call }.to change(Project, :count).by(2)
      end

      it "maps gem attributes to project fields" do
        described_class.call
        project = Project.find_by(rubygem_name: "safe_memoize")
        expect(project.name).to eq("safe_memoize")
        expect(project.description).to eq("A memoization library.")
        expect(project.url).to eq("https://rubygems.org/gems/safe_memoize")
        expect(project.source_url).to eq("https://github.com/eclectic-coding/safe_memoize")
        expect(project.version).to eq("1.7.0")
        expect(project.project_type).to eq("rubygem")
      end

      it "returns the count of imported gems" do
        expect(described_class.call.imported).to eq(2)
      end

      it "returns skipped: 0 when all gems are new" do
        expect(described_class.call.skipped).to eq(0)
      end

      it "skips gems already tracked by rubygem_name" do
        create(:project, :rubygem, rubygem_name: "safe_memoize")
        result = described_class.call
        expect(result.imported).to eq(1)
        expect(result.skipped).to eq(1)
      end

      it "omits source_url when homepage_uri is nil" do
        described_class.call
        expect(Project.find_by(rubygem_name: "another_gem").source_url).to be_nil
      end

      it "omits source_url when homepage_uri is not http/https" do
        gem_payload.first["homepage_uri"] = "ftp://not-safe.com"
        described_class.call
        expect(Project.find_by(rubygem_name: "safe_memoize").source_url).to be_nil
      end
    end

    context "when RubygemsService returns no gems" do
      before { allow(RubygemsService).to receive(:gems).and_return([]) }

      it "returns gems_found: false" do
        expect(described_class.call.gems_found).to be false
      end

      it "does not create any projects" do
        expect { described_class.call }.not_to change(Project, :count)
      end

      it "returns zero counts" do
        result = described_class.call
        expect(result.imported).to eq(0)
        expect(result.skipped).to eq(0)
      end
    end
  end
end
