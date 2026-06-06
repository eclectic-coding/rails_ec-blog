require "rails_helper"

RSpec.describe "Dashboard tag management", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
    @tag = create(:tag, name: "ruby")
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:rack_test)
    visit test_sign_in_path(@admin)
  end

  describe "new tag" do
    before(:each) { visit new_dashboard_tag_path }

    it "has the New Tag heading" do
      expect(page).to have_css("h1", text: "New Tag")
    end

    it "has a name field" do
      expect(page).to have_field("Name")
    end

    it "has a Create tag submit button" do
      expect(page).to have_button("Create tag")
    end

    it "has a Cancel link back to the tags index" do
      expect(page).to have_link("Cancel", href: dashboard_tags_path)
    end

    it "creates a tag and redirects to the tag show page" do
      fill_in "Name", with: "rails"
      click_button "Create tag"
      expect(page).to have_text("Tag was successfully created.")
    end

    it "shows validation errors when submitted without a name" do
      click_button "Create tag"
      expect(page).to have_text("Name can't be blank")
    end
  end

  describe "edit tag" do
    before(:each) { visit edit_dashboard_tag_path(@tag) }

    it "has the Edit Tag heading" do
      expect(page).to have_css("h1", text: "Edit Tag")
    end

    it "pre-fills the name field with the tag name" do
      expect(page).to have_field("Name", with: @tag.name)
    end

    it "has a Save changes submit button" do
      expect(page).to have_button("Save changes")
    end

    it "has a Cancel link back to the tag show page" do
      expect(page).to have_link("Cancel", href: dashboard_tag_path(@tag.id))
    end

    it "saves changes and shows a success notice" do
      fill_in "Name", with: "updated-ruby"
      click_button "Save changes"
      expect(page).to have_text("Tag was successfully updated.")
    end
  end

  describe "delete tag" do
    before(:each) do
      @tag_to_delete = create(:tag, name: "deleteme")
      visit dashboard_tags_path
    end

    after(:each) { Tag.find_by(name: "deleteme")&.destroy }

    it "removes the tag and shows a success notice" do
      within("tr", text: "Deleteme") { click_button "Delete" }
      expect(page).to have_text("Tag was successfully deleted.")
    end

    it "no longer shows the deleted tag in the list" do
      within("tr", text: "Deleteme") { click_button "Delete" }
      expect(page).not_to have_text("Deleteme")
    end
  end
end
