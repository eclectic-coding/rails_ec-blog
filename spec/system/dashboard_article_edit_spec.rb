require "rails_helper"

RSpec.describe "Dashboard article edit", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
    @article = create(:article, :published, user: @admin)
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:rack_test)
    visit test_sign_in_path(@admin)
  end

  describe "edit link" do
    before(:each) { visit dashboard_articles_path }

    it "navigates to the edit form" do
      click_link "Edit"
      expect(page).to have_current_path(edit_dashboard_article_path(@article))
    end
  end

  describe "edit form" do
    before(:each) do
      @article.reload
      visit edit_dashboard_article_path(@article)
    end

    it "has the Edit Article heading" do
      expect(page).to have_css("h1", text: "Edit Article")
    end

    it "pre-fills the title field with the article title" do
      expect(page).to have_field("Title", with: @article.title)
    end

    it "has an Update Article submit button" do
      expect(page).to have_button("Update Article")
    end

    it "has a Cancel link back to the article show page" do
      expect(page).to have_link("Cancel", href: dashboard_article_path(@article))
    end

    it "has a back link to the articles index" do
      expect(page).to have_link("← Articles", href: dashboard_articles_path)
    end

    it "saves changes and shows a success notice" do
      fill_in "Title", with: "#{@article.title} edited"
      first(:button, "Update Article").click
      expect(page).to have_text("Article was successfully updated.")
    end
  end
end
