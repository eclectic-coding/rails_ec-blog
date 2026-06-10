require "rails_helper"

RSpec.describe Article, type: :model do
  describe 'associations' do
    it 'belongs to user' do
      article = create(:article)
      expect(article.user).to be_present
      expect(article.user).to be_a(User)
    end

    it 'has many article_tags' do
      article = create(:article)
      tag = create(:tag)
      article.tags << tag

      expect(article.article_tags.count).to eq(2) # 1 from factory + 1 added
    end

    it 'has many tags through article_tags' do
      article = create(:article)
      tag = create(:tag, name: 'ruby')
      article.tags << tag

      expect(article.tags.pluck(:name)).to include('ruby')
    end

    it 'destroys article_tags when destroyed' do
      article = create(:article)

      expect { article.destroy }.to change { ArticleTag.count }.by(-1)
    end
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:tag) { create(:tag) }

    it 'requires at least one tag' do
      article = build(:article, user: user)
      article.tags = [] # Clear tags added by factory
      expect(article).not_to be_valid
      expect(article.errors[:tags]).to include('must have at least one tag')
    end

    it 'is valid with at least one tag' do
      article = build(:article, user: user, tags: [tag])
      expect(article).to be_valid
    end
  end

  describe "normalize_published_at" do
    it "normalizes a bare Date to a Time via PublishedAtNormalizer" do
      article = build(:article, user: build_stubbed(:user), published_at: Date.new(2025, 6, 1))
      article.valid?
      expect(article.published_at).to be_a(Time)
      expect(article.published_at.to_date).to eq(Date.new(2025, 6, 1))
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

  describe ".sorted" do
    let(:user)   { create(:user) }
    let!(:alpha) { create(:article, title: "Alpha", user: user) }
    let!(:beta)  { create(:article, title: "Beta",  user: user) }
    let!(:gamma) { create(:article, title: "Gamma", user: user) }

    it "sorts by title ascending" do
      expect(Article.sorted("title", "asc").map(&:title)).to eq(%w[Alpha Beta Gamma])
    end

    it "sorts by title descending" do
      expect(Article.sorted("title", "desc").map(&:title)).to eq(%w[Gamma Beta Alpha])
    end

    it "sorts by date ascending" do
      result = Article.sorted("date", "asc").to_a
      expect(result.first).to eq(alpha)
      expect(result.last).to eq(gamma)
    end

    it "sorts by date descending" do
      result = Article.sorted("date", "desc").to_a
      expect(result.first).to eq(gamma)
      expect(result.last).to eq(alpha)
    end

    it "sorts by status ascending (drafts first)" do
      published = create(:article, :published, user: user)
      draft     = create(:article, user: user)
      result    = Article.sorted("status", "asc").to_a
      expect(result.index(draft)).to be < result.index(published)
    end

    it "sorts by status descending (published first)" do
      published = create(:article, :published, user: user)
      draft     = create(:article, user: user)
      result    = Article.sorted("status", "desc").to_a
      expect(result.index(published)).to be < result.index(draft)
    end

    it "falls back to recent order for unrecognised column" do
      expect(Article.sorted("unknown", "asc")).to eq(Article.recent)
    end
  end

  describe "OG image generation" do
    it "enqueues OgImageGenerationJob after commit for a published article with an image" do
      article = create(:article, :published)

      expect {
        article.update!(title: "New Title #{SecureRandom.hex(4)}")
      }.to have_enqueued_job(OgImageGenerationJob).with(article.id)
    end

    it "does not enqueue the job for a draft article" do
      article = create(:article)

      expect {
        article.update!(title: "Draft Title #{SecureRandom.hex(4)}")
      }.not_to have_enqueued_job(OgImageGenerationJob)
    end

    it "enqueues the job when a draft is published" do
      article = create(:article)

      expect {
        article.update!(is_published: true)
      }.to have_enqueued_job(OgImageGenerationJob).with(article.id)
    end

    it "does not enqueue the job when a published article has no image" do
      article = create(:article, :published)
      article.image.purge
      article.reload
      article.remove_image = true  # bypass image-presence validation

      expect {
        article.update!(title: "No Image #{SecureRandom.hex(4)}")
      }.not_to have_enqueued_job(OgImageGenerationJob)
    end
  end
end
