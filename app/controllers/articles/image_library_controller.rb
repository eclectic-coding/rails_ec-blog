module Articles
  class ImageLibraryController < ApplicationController
    before_action :admin_only!

    # GET /articles/image_library
    def index
      @blobs = ActiveStorage::Blob
        .joins(:attachments)
        .where(active_storage_attachments: { record_type: "Article", name: "image" })
        .distinct
        .order(created_at: :desc)
    end
  end
end
