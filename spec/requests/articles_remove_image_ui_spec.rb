require 'rails_helper'

RSpec.describe "Remove image UI", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  it 'renders a remove control that triggers Stimulus or a form (has data-remove-url and data-action) when an image is attached' do
    article = create(:article, user: user)

    fixture_path = Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')
    article.image.attach(io: File.open(fixture_path), filename: 'test_image.jpg', content_type: 'image/jpeg')
    article.save!

    sign_in_as(admin)

    get edit_article_path(article)
    expect(response).to have_http_status(:ok)

    body = response.body
    # ensure there is a remove control rendered as a button with Stimulus data attributes
    expect(body).to include("data-action=\"click->file-preview#removeImage\"")
    expect(body).to include("data-remove-url=\"")
    expect(body).to include(remove_image_article_path(article))
  end
end
