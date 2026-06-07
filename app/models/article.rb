class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user

  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  has_rich_text :content

  has_one_attached :image

  # Virtual attribute used by the form to indicate the user wants to remove the current attachment
  attr_accessor :remove_image

  validates :title, presence: true
  validates :tags, presence: { message: "must have at least one tag" }

  validate :image_presence
  validate :image_type_and_size
  validate :no_missing_attachments_in_content

  scope :published, -> { where(is_published: true) }
  scope :draft, -> { where(is_published: false) }
  scope :recent, -> { order(Arel.sql("COALESCE(articles.published_at, articles.created_at) DESC, articles.created_at DESC")) }

  before_validation :normalize_published_at
  before_save :autoset_published_at, if: -> { will_save_change_to_is_published? }


  def self.sorted(column, direction)
    case [column, direction]
    when ["title", "asc"]  then order(Arel.sql("articles.title ASC"))
    when ["title", "desc"] then order(Arel.sql("articles.title DESC"))
    when ["date",  "asc"]  then order(Arel.sql("COALESCE(articles.published_at, articles.created_at) ASC"))
    when ["date",  "desc"] then order(Arel.sql("COALESCE(articles.published_at, articles.created_at) DESC"))
    when ["tags",  "asc"]  then order(Arel.sql("(SELECT MIN(tags.name) FROM tags INNER JOIN article_tags ON article_tags.tag_id = tags.id WHERE article_tags.article_id = articles.id) ASC"))
    when ["tags",  "desc"] then order(Arel.sql("(SELECT MIN(tags.name) FROM tags INNER JOIN article_tags ON article_tags.tag_id = tags.id WHERE article_tags.article_id = articles.id) DESC"))
    else recent
    end
  end

  def self.visible_to(user)
    if user&.admin?
      all.recent
    else
      published.recent
    end
  end

  private

  def normalize_published_at
    return if published_at.blank?

    # If a Date was assigned (or a date-like string was parsed to a Date), convert to the same date
    # but use the current time-of-day so articles with the same date sort by time.
    if published_at.is_a?(Date) && !published_at.is_a?(Time)
      now = Time.current
      self.published_at = Time.zone.local(published_at.year, published_at.month, published_at.day,
                                          now.hour, now.min, now.sec)
    elsif published_at.is_a?(String)
      parsed = Time.zone.parse(published_at) rescue nil
      if parsed
        # If the parsed time has zeroed time components, use current time-of-day on that date
        if parsed.hour == 0 && parsed.min == 0 && parsed.sec == 0
          now = Time.current
          self.published_at = Time.zone.local(parsed.year, parsed.month, parsed.day,
                                              now.hour, now.min, now.sec)
        else
          self.published_at = parsed.in_time_zone
        end
      end
    elsif published_at.respond_to?(:hour) && published_at.hour == 0 && published_at.min == 0 && published_at.sec == 0
      # Handle values that were typecast to Time/TimeWithZone at midnight (e.g., assigning a Date to a datetime column).
      now = Time.current
      self.published_at = Time.zone.local(published_at.year, published_at.month, published_at.day,
                                          now.hour, now.min, now.sec)
    end
  end

  def autoset_published_at
    if is_published?
      self.published_at = Time.current if published_at.blank?
    else
      self.published_at = nil
    end
  end

  # Simple Active Storage validations: size and content type
  def image_type_and_size
    return unless image.attached?

    allowed = %w[image/jpeg image/png image/webp image/gif]
    unless image.content_type.in?(allowed)
      errors.add(:image, "must be a JPEG, PNG, WEBP or GIF")
    end

    if image.blob.byte_size > 5.megabytes
      errors.add(:image, "size must be less than 5MB")
    end
  end

  # Ensure an image is attached
  def image_presence
    # If the form requested removal, allow no attachment
    return if remove_image.present?

    errors.add(:image, "must be attached") unless image.attached?
  end

  # Prevent saving content that contains unresolvable (embedded) image attachments.
  # This happens when a user pastes markdown that includes inline images — the editor
  # creates an <action-text-attachment> node whose sgid can't be resolved to an
  # Active Storage blob, which would cause a 500 on the show page.
  def no_missing_attachments_in_content
    body = content.body
    return unless body.present?

    body.attachments.each do |attachment|
      next unless attachment.attachable.is_a?(ActionText::Attachables::MissingAttachable)

      errors.add(:content,
        "contains an embedded image that could not be processed. " \
        "Please remove inline images from your pasted content and use " \
        "the image upload button instead.")
      return
    end
  rescue => e
    Rails.logger.warn(
      "[Article] Content attachment check raised an error: #{e.class}: #{e.message}\n" \
      "#{Array(e.backtrace).first(5).join("\n")}"
    )
  end
end
