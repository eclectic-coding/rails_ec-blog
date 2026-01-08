require 'rails_helper'

RSpec.describe "Article image uploads", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "does not show the image on the show page" do
    user = create(:user)
    article = create(:article, :published, user: user)
    article.image.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")), filename: "test_image.jpg", content_type: "image/jpeg")

    visit article_path(article)

    expect(page).to have_no_css("img")
  end

  it "shows thumbnails on index" do
    user = create(:user)
    article = create(:article, :published, user: user)
    article.image.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_image.jpg")), filename: "test_image.jpg", content_type: "image/jpeg")

    visit articles_path

    expect(page).to have_css("img")
  end
end
