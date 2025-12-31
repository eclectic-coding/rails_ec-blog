require 'rails_helper'

RSpec.describe "DELETE /articles/:id/remove_image", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:fixture_path) { Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg') }

  it "removes the attached image and responds with turbo_stream" do
    article = create(:article, user: user)

    # attach a fixture image
    article.image.attach(io: File.open(fixture_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
    article.save!
    expect(article.image.attached?).to be true

    sign_in_as(admin)

    delete remove_image_article_path(article), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

    article.reload
    expect(article.image.attached?).to be false

    expect(response.content_type).to include('turbo-stream')
    expect(response.body).to include("article-image-area-#{article.id}")
    expect(response.body).to include('Image removed.')
  end

  it "returns a notice when remove_image is present but no image was attached" do
    article = create(:article, user: user)
    # ensure no attachment
    article.image.purge if article.image.attached?

    sign_in_as(admin)

    delete remove_image_article_path(article), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }

    article.reload
    expect(article.image.attached?).to be false

    expect(response.content_type).to include('turbo-stream')
    expect(response.body).to include('No image was attached')
  end
end
