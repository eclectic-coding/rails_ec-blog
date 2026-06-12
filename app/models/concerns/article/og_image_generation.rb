module Article::OgImageGeneration
  extend ActiveSupport::Concern

  included do
    before_save :capture_image_change
    after_commit :enqueue_og_image_generation, if: :should_regenerate_og_image?
  end

  private

  def capture_image_change
    @image_changed = attachment_changes["image"].present?
  end

  def should_regenerate_og_image?
    return false unless is_published? && image.attached?

    saved_change_to_title? || !og_image.attached? || @image_changed
  end

  def enqueue_og_image_generation
    OgImageGenerationJob.perform_later(id)
  end
end
