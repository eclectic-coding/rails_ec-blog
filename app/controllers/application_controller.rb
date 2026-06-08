class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_default_meta_tags

  private

  def set_default_meta_tags
    set_meta_tags(
      site:        "Eclectic Coding",
      description: "Senior Software Engineer writing about Ruby on Rails, " \
                   "open source, and software craftsmanship.",
      separator:   "|",
      og: {
        site_name: "Eclectic Coding",
        type:      "website",
        locale:    "en_US"
      },
      twitter: {
        card: "summary_large_image",
        site: "@eclecticcoding"
      },
      canonical: request.original_url
    )
  end
end
