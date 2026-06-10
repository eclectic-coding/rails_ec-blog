module Article::OgImageGeneration
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_og_image_generation, if: :should_regenerate_og_image?
  end

  private

  def should_regenerate_og_image?
    return false unless is_published? && image.attached?

    saved_change_to_title? || !og_image.attached? || image_newer_than_og_card?
  end

  def image_newer_than_og_card?
    image.blob.created_at > og_image.blob.created_at
  end

  def enqueue_og_image_generation
    OgImageGenerationJob.perform_later(id)
  end
end
