require "rails_helper"

RSpec.describe ProjectSyncJob, type: :job do
  let!(:gem_project) do
    create(:project, :rubygem,
      rubygem_name: "safe_memoize",
      version: "1.0.0",
      description: "Old description")
  end

  let!(:non_gem_project) { create(:project) }

  let(:gem_api_response) do
    { "version" => "1.8.0", "info" => "Updated description." }.to_json
  end

  def stub_rubygems_api(name, body: gem_api_response, status: "200")
    stub_request(:get, "https://rubygems.org/api/v1/gems/#{name}.json")
      .to_return(status: status.to_i, body: body, headers: { "Content-Type" => "application/json" })
  end

  describe "#perform" do
    it "updates version and description for projects with a rubygem_name" do
      stub_rubygems_api("safe_memoize")

      described_class.perform_now

      gem_project.reload
      expect(gem_project.version).to eq("1.8.0")
      expect(gem_project.description).to eq("Updated description.")
      expect(gem_project.last_synced_at).to be_within(5.seconds).of(Time.current)
    end

    it "does not touch projects without a rubygem_name" do
      stub_rubygems_api("safe_memoize")

      expect { described_class.perform_now }
        .not_to change { non_gem_project.reload.updated_at }
    end

    it "continues processing remaining gems when one raises an error" do
      second_gem = create(:project, :rubygem, rubygem_name: "other_gem", version: "0.1.0")

      stub_request(:get, "https://rubygems.org/api/v1/gems/safe_memoize.json")
        .to_raise(SocketError.new("connection failed"))
      stub_rubygems_api("other_gem", body: { "version" => "0.2.0", "info" => "desc" }.to_json)

      expect { described_class.perform_now }.not_to raise_error

      expect(second_gem.reload.version).to eq("0.2.0")
    end

    it "logs a warning and skips update when the API returns a non-success status" do
      stub_rubygems_api("safe_memoize", status: "404", body: "Not found")

      expect(Rails.logger).to receive(:warn).with(/safe_memoize.*404/)

      described_class.perform_now

      expect(gem_project.reload.version).to eq("1.0.0")
    end

    it "does not overwrite name, url, is_featured, or position" do
      stub_rubygems_api("safe_memoize")

      original = gem_project.slice(:name, :url, :is_featured, :position)
      described_class.perform_now
      gem_project.reload

      expect(gem_project.name).to eq(original["name"])
      expect(gem_project.url).to eq(original["url"])
      expect(gem_project.is_featured).to eq(original["is_featured"])
      expect(gem_project.position).to eq(original["position"])
    end
  end
end
