require "rails_helper"

RSpec.describe "Dashboard article sort", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
    create(:article, title: "Alpha Article", user: @admin)
    create(:article, title: "Beta Article",  user: @admin)
    create(:article, title: "Gamma Article", user: @admin)
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:headless_chrome)
    visit test_sign_in_path(@admin)
    visit dashboard_articles_path
  end

  it "sorts by title ascending without a full page reload" do
    click_link "Title"

    expect(page).to have_current_path(/sort=title/)
    titles = all("tbody tr td.fw-medium").map(&:text)
    expect(titles).to eq(titles.sort)
  end

  it "toggles title sort to descending on second click" do
    click_link "Title"
    click_link "Title"

    expect(page).to have_current_path(/direction=desc/)
    titles = all("tbody tr td.fw-medium").map(&:text)
    expect(titles).to eq(titles.sort.reverse)
  end

  it "sorts by date without a full page reload" do
    click_link "Date"

    expect(page).to have_current_path(/sort=date/)
    expect(page).to have_css("tbody tr")
  end

  it "sorts by status without a full page reload" do
    within("thead") { click_link "Status" }

    expect(page).to have_current_path(/sort=status/)
    expect(page).to have_css("tbody tr")
  end

  it "shows a sort indicator on the active column" do
    click_link "Title"

    within("thead") { expect(page).to have_text(/Title\s*[↑↓]/) }
  end
end
