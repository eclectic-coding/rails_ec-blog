require "rails_helper"

RSpec.describe "Dashboard article delete", type: :system do
  include_context "database cleanup"

  let(:admin) { create(:user, :admin) }
  let!(:article) { create(:article, user: admin) }

  before(:each) do
    driven_by(:headless_chrome)
    visit test_sign_in_path(admin)
    visit dashboard_articles_path
  end

  after(:all) { purge_all_records }

  it "removes the row via Turbo without a full page reload" do
    row_id = ActionView::RecordIdentifier.dom_id(article)

    expect(page).to have_css("##{row_id}")

    page.evaluate_script("window.confirm = function() { return true; }")
    within("##{row_id}") { click_button "Delete" }

    expect(page).not_to have_css("##{row_id}")
    expect(page).to have_current_path(dashboard_articles_path)
  end
end
