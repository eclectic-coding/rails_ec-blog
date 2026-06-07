require "rails_helper"

RSpec.describe "Dashboard article search", type: :system do
  include_context "database cleanup"

  before(:all) do
    purge_all_records
    @admin = create(:user, :admin)
    create(:article, title: "Rails Routing Guide", user: @admin)
    create(:article, title: "Stimulus Handbook",   user: @admin)
    create(:article, title: "Turbo Frames Deep Dive", user: @admin)
  end

  after(:all) { purge_all_records }

  before(:each) do
    driven_by(:headless_chrome)
    visit test_sign_in_path(@admin)
    visit dashboard_articles_path
  end

  it "has the search input wired to the article-search stimulus controller" do
    input = find("input[name='q']")
    expect(input["data-action"]).to include("article-search#search")
    expect(input["data-article-search-target"]).to eq("input")
  end

  it "filters the table when the q param is present" do
    visit dashboard_articles_path(q: "Rail")
    expect(page).to have_css("tbody tr", count: 1)
    expect(page).to have_text("Rails Routing Guide")
    expect(page).not_to have_text("Stimulus Handbook")
  end

  it "shows all articles when query is blank" do
    visit dashboard_articles_path(q: "Rail")
    expect(page).to have_css("tbody tr", count: 1)

    visit dashboard_articles_path
    expect(page).to have_css("tbody tr", count: 3)
  end

  it "preserves the search term when sorting" do
    visit dashboard_articles_path(q: "Rail")
    expect(page).to have_css("tbody tr", count: 1)

    click_link "Title"
    expect(page).to have_current_path(/q=Rail/)
    expect(page).to have_css("tbody tr", count: 1)
  end
end
