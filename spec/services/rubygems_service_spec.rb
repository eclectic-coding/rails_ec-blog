require "rails_helper"

RSpec.describe RubygemsService do
  before { allow(described_class).to receive(:username).and_return("eclecticCoding") }

  let(:api_url) { "https://rubygems.org/api/v1/owners/eclecticCoding/gems.json" }

  let(:gem_payload) do
    [
      {
        "name"           => "safe_memoize",
        "version"        => "1.7.0",
        "downloads"      => 2890,
        "info"           => "A memoization library for Ruby.",
        "project_uri"    => "https://rubygems.org/gems/safe_memoize",
        "homepage_uri"   => "https://github.com/eclectic-coding/safe_memoize",
        "changelog_uri"  => "https://github.com/eclectic-coding/safe_memoize/blob/main/CHANGELOG.md"
      }
    ].to_json
  end

  before { Rails.cache.clear }

  describe ".gems" do
    context "when the API returns a successful response" do
      before do
        stub_request(:get, api_url).to_return(status: 200, body: gem_payload, headers: { "Content-Type" => "application/json" })
      end

      it "returns an array of gem hashes" do
        result = described_class.gems
        expect(result).to be_an(Array)
        expect(result.first["name"]).to eq("safe_memoize")
      end

      it "caches the result so the API is only called once" do
        memory_cache = ActiveSupport::Cache::MemoryStore.new
        allow(Rails).to receive(:cache).and_return(memory_cache)
        2.times { described_class.gems }
        expect(WebMock).to have_requested(:get, api_url).once
      end
    end

    context "when the API returns a non-success response" do
      before do
        stub_request(:get, api_url).to_return(status: 404, body: "Owner could not be found.")
      end

      it "returns an empty array" do
        expect(described_class.gems).to eq([])
      end
    end

    context "when a network error occurs" do
      before do
        stub_request(:get, api_url).to_raise(SocketError)
      end

      it "returns an empty array" do
        expect(described_class.gems).to eq([])
      end
    end
  end
end
