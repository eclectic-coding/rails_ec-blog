require "rails_helper"

RSpec.describe "Dashboard user edit", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
    @user = create(:user)
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:rack_test)
    visit test_sign_in_path(@admin)
  end

  describe "edit link" do
    before(:each) { visit dashboard_users_path }

    it "navigates to the edit form" do
      within("tr", text: @user.email_address) { click_link "Edit" }
      expect(page).to have_current_path(edit_dashboard_user_path(@user))
    end
  end

  describe "edit form" do
    before(:each) { visit edit_dashboard_user_path(@user) }

    it "has the Edit User heading" do
      expect(page).to have_css("h1", text: "Edit User")
    end

    it "pre-fills the email field" do
      expect(page).to have_field("Email address", with: @user.email_address)
    end

    it "has an admin checkbox" do
      expect(page).to have_field("Administrator", type: "checkbox")
    end

    it "has a password field" do
      expect(page).to have_field("Password", type: "password")
    end

    it "has a password confirmation field" do
      expect(page).to have_field("Password confirmation", type: "password")
    end

    it "has a Save changes submit button" do
      expect(page).to have_button("Save changes")
    end

    it "has a Cancel link back to the user show page" do
      expect(page).to have_link("Cancel", href: dashboard_user_path(@user))
    end

    it "saves a new email and shows a success notice" do
      fill_in "Email address", with: "updated@example.com"
      click_button "Save changes"
      expect(page).to have_text("User was successfully updated.")
    end

    it "shows a validation error for a blank email" do
      fill_in "Email address", with: ""
      click_button "Save changes"
      expect(page).to have_text("Email address can't be blank")
    end
  end
end
