require "rails_helper"
require "active_support/testing/time_helpers"

RSpec.describe Article, type: :model do

  describe "normalize_published_at" do
    include ActiveSupport::Testing::TimeHelpers

    let(:user) { build_stubbed(:user) }

    around do |example|
      # Freeze time to have deterministic expectations for time-of-day usage
      travel_to(Time.zone.local(2025, 12, 30, 14, 35, 20)) do
        example.run
      end
    end

    it "uses current time-of-day when a Date is assigned" do
      article = build(:article, user: user, published_at: Date.new(2025, 12, 25))

      article.valid? # triggers before_validation

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 25, 14, 35, 20))
    end

    it "parses date-only string and uses current time-of-day" do
      article = build(:article, user: user, published_at: "2025-12-20")

      article.valid?

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 20, 14, 35, 20))
    end

    it "parses datetime string and preserves time component" do
      article = build(:article, user: user, published_at: "2025-12-24 09:15:00")

      article.valid?

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 24, 9, 15, 0))
    end

    it "does nothing when published_at is blank or nil" do
      article = build(:article, user: user, published_at: nil)

      article.valid?

      expect(article.published_at).to be_nil
    end

    it "uses current time-of-day when the reader initially returns a Date (not a Time)" do
      article = build(:article, user: user)

      # Temporarily override the instance reader so every read returns a
      # Date object. This ensures that multiple reads inside
      # `normalize_published_at` observe the same Date value and the
      # Date-specific branch is exercised. After running the method we
      # remove the override so subsequent reads return the real value.
      article.define_singleton_method(:published_at) do
        Date.new(2025, 12, 26)
      end

      article.send(:normalize_published_at)

      # Restore the original reader so `article.published_at` returns the
      # attribute value set by the model (the singleton method shadows the
      # original reader, so remove it from the singleton class).
      article.singleton_class.send(:remove_method, :published_at)

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 26, 14, 35, 20))
    end

    it "ignores unparsable string values for published_at" do
      article = build(:article, user: user, published_at: "not-a-date")

      # If parsing fails, the code rescues and leaves published_at alone
      article.valid?

      expect(article.published_at).to be_nil
    end

    it "treats an ISO midnight datetime string as date-only and uses current time-of-day" do
      article = build(:article, user: user, published_at: "2025-12-20T00:00:00")

      article.valid?

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 20, 14, 35, 20))
    end

    # --- New tests to ensure the `published_at.is_a?(String)` branch is hit ---
    it "handles a date-only String when published_at is a String" do
      article = build(:article, user: user)

      # Force the reader to return a String so the `is_a?(String)` branch runs
      article.define_singleton_method(:published_at) { "2025-12-21" }

      article.send(:normalize_published_at)
      article.singleton_class.send(:remove_method, :published_at)

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 21, 14, 35, 20))
    end

    it "handles a datetime String (non-midnight) when published_at is a String" do
      article = build(:article, user: user)

      article.define_singleton_method(:published_at) { "2025-12-22 08:10:05" }

      article.send(:normalize_published_at)
      article.singleton_class.send(:remove_method, :published_at)

      expect(article.published_at).to be_present
      expect(article.published_at).to be_within(1.second).of(Time.zone.local(2025, 12, 22, 8, 10, 5))
    end

    it "ignores an unparsable String when published_at is a String" do
      article = build(:article, user: user)

      article.define_singleton_method(:published_at) { "not-a-date" }

      article.send(:normalize_published_at)
      article.singleton_class.send(:remove_method, :published_at)

      expect(article.published_at).to be_nil
    end

  end

  describe "image_type_and_size" do
    let(:user) { build_stubbed(:user) }

    it "adds an error for disallowed content types" do
      article = build(:article, user: user)
      article.image.attach(io: StringIO.new("not an image"), filename: "file.txt", content_type: "text/plain")

      article.valid?

      expect(article.errors[:image]).to include("must be a JPEG, PNG, WEBP or GIF")
    end

    it "adds an error for images larger than 5MB" do
      article = build(:article, user: user)
      big_io = StringIO.new("a" * (5.megabytes + 1))
      article.image.attach(io: big_io, filename: "big.png", content_type: "image/png")

      article.valid?

      expect(article.errors[:image]).to include("size must be less than 5MB")
    end

    it "is valid for an allowed small image" do
      article = build(:article, user: user)
      small_io = StringIO.new("a" * 1024)
      article.image.attach(io: small_io, filename: "small.jpg", content_type: "image/jpeg")

      expect(article).to be_valid
    end
  end
end
