require "rails_helper"

RSpec.describe Article::PublishedAtNormalizer do
  let(:now) { Time.zone.local(2025, 12, 30, 14, 35, 20) }

  def normalize(value)
    described_class.call(value, now: now)
  end

  it "returns nil unchanged" do
    expect(normalize(nil)).to be_nil
  end

  it "returns a blank string unchanged" do
    expect(normalize("")).to eq("")
  end

  it "replaces the time-of-day on a bare Date with the current time" do
    result = normalize(Date.new(2025, 12, 25))
    expect(result).to eq(Time.zone.local(2025, 12, 25, 14, 35, 20))
  end

  it "parses a date-only string and applies the current time-of-day" do
    result = normalize("2025-12-20")
    expect(result).to be_within(1.second).of(Time.zone.local(2025, 12, 20, 14, 35, 20))
  end

  it "parses a datetime string and preserves its time component" do
    result = normalize("2025-12-24 09:15:00")
    expect(result).to be_within(1.second).of(Time.zone.local(2025, 12, 24, 9, 15, 0))
  end

  it "treats a midnight datetime string as date-only and applies the current time-of-day" do
    result = normalize("2025-12-20T00:00:00")
    expect(result).to be_within(1.second).of(Time.zone.local(2025, 12, 20, 14, 35, 20))
  end

  it "returns the original string when it cannot be parsed" do
    expect(normalize("not-a-date")).to eq("not-a-date")
  end

  it "replaces the time-of-day on a Time/TimeWithZone value that is at midnight" do
    midnight = Time.zone.local(2025, 12, 26, 0, 0, 0)
    result   = normalize(midnight)
    expect(result).to eq(Time.zone.local(2025, 12, 26, 14, 35, 20))
  end

  it "passes through a Time value whose time-of-day is already set" do
    afternoon = Time.zone.local(2025, 12, 26, 9, 30, 0)
    expect(normalize(afternoon)).to eq(afternoon)
  end
end
