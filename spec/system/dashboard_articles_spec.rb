require "rails_helper"

RSpec.describe "Dashboard articles index", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
    create_list(:article, 15, user: @admin)              # 15 drafts — bulk fill (oldest timestamps)
    create(:article, :published, user: @admin)           # 1 published — newest, triggers pagination (16 total)
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:headless_chrome)
    visit test_sign_in_path(@admin)
    visit dashboard_articles_path
  end

  it "displays articles" do
    expect(page).to have_css("table tbody tr", minimum: 1)
  end

  it "shows a published badge" do
    expect(page).to have_css(".badge.text-bg-success", text: "Published")
  end

  it "shows a draft badge" do
    expect(page).to have_css(".badge.text-bg-warning", text: "Draft")
  end

  it "has a New Article link" do
    expect(page).to have_link("New Article", href: new_dashboard_article_path)
  end

  describe "pagination" do
    it "shows a page 2 link" do
      expect(page).to have_link("2")
    end

    it "navigates to page 2" do
      click_link "2"
      expect(page).to have_current_path(dashboard_articles_path(page: 2))
    end
  end
end
