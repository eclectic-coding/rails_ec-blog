require "rails_helper"

RSpec.describe "Dashboard navigation", type: :system do
  before(:all) { @admin = create(:user, :admin) }
  after(:all) { Session.delete_all; User.delete_all }

  before(:each) do
    driven_by(:headless_chrome)
    visit test_sign_in_path(@admin)
  end

  describe "sidebar" do
    before(:each) { visit dashboard_root_path }

    it "Dashboard link goes to dashboard root" do
      within("aside") { click_link "Dashboard" }
      expect(page).to have_current_path(dashboard_root_path)
    end

    it "Articles link goes to dashboard articles index" do
      within("aside") { click_link "Articles" }
      expect(page).to have_current_path(dashboard_articles_path)
    end

    it "Tags link goes to dashboard tags index" do
      within("aside") { click_link "Tags" }
      expect(page).to have_current_path(dashboard_tags_path)
    end

    it "Users link goes to dashboard users index" do
      within("aside") { click_link "Users" }
      expect(page).to have_current_path(dashboard_users_path)
    end

    it "Public site link goes to root" do
      within("aside") { click_link "← Public site" }
      expect(page).to have_current_path(root_path)
    end

    it "Sign Out ends the session and redirects to sign-in" do
      within("aside") { click_button "Sign Out" }
      expect(page).to have_current_path(new_session_path)
    end
  end

  describe "dashboard index" do
    before(:each) { visit dashboard_root_path }

    it "Total Articles 'View all' goes to articles index" do
      first("a", text: "View all").click
      expect(page).to have_current_path(dashboard_articles_path)
    end

    it "Tags 'View all' goes to tags index" do
      find("a[href='#{dashboard_tags_path}']", text: "View all").click
      expect(page).to have_current_path(dashboard_tags_path)
    end

    it "Users 'View all' goes to users index" do
      find("a[href='#{dashboard_users_path}']", text: "View all").click
      expect(page).to have_current_path(dashboard_users_path)
    end

    it "Manage Articles quick action goes to articles index" do
      find("a[href='#{dashboard_articles_path}']", text: "Manage Articles").click
      expect(page).to have_current_path(dashboard_articles_path)
    end

    it "Manage Users quick action goes to users index" do
      find("a[href='#{dashboard_users_path}']", text: "Manage Users").click
      expect(page).to have_current_path(dashboard_users_path)
    end

    it "Manage Tags quick action goes to tags index" do
      find("a[href='#{dashboard_tags_path}']", text: "Manage Tags").click
      expect(page).to have_current_path(dashboard_tags_path)
    end

    it "Manage Projects quick action goes to projects index" do
      find("a[href='#{dashboard_projects_path}']", text: "Manage Projects").click
      expect(page).to have_current_path(dashboard_projects_path)
    end
  end
end
