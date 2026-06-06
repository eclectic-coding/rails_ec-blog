require "rails_helper"

RSpec.describe "Dashboard article new", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:rack_test)
    visit test_sign_in_path(@admin)
  end

  describe "new article link" do
    before(:each) { visit dashboard_articles_path }

    it "navigates to the new article form" do
      click_link "New Article"
      expect(page).to have_current_path(new_dashboard_article_path)
    end
  end

  describe "new article form" do
    before(:each) { visit new_dashboard_article_path }

    it "has the New Article heading" do
      expect(page).to have_css("h1", text: "New Article")
    end

    it "has a title field" do
      expect(page).to have_field("Title")
    end

    it "has a Create Article submit button" do
      expect(page).to have_button("Create Article")
    end

    it "has a Cancel link back to the articles index" do
      expect(page).to have_link("Cancel", href: dashboard_articles_path)
    end

    it "has a back link to the articles index" do
      expect(page).to have_link("← Articles", href: dashboard_articles_path)
    end

    it "shows validation errors when submitted without a title" do
      click_button "Create Article"
      expect(page).to have_text("Title can't be blank")
    end
  end
end