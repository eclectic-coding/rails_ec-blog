class Article < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  include Article::OgImageGeneration

  belongs_to :user

  has_many :article_tags, dependent: :destroy
  has_many :tags, through: :article_tags

  has_rich_text :content

  has_one :project

  has_one_attached :image
  has_one_attached :og_image

  # Virtual attribute used by the form to indicate the user wants to remove the current attachment
  attr_accessor :remove_image

  validates :title, presence: true
  validates :tags, presence: { message: "must have at least one tag" }
  validates :content, missing_action_text_attachments: true

  validate :image_presence
  validate :image_type_and_size

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
    when ["status", "asc"]  then order(Arel.sql("articles.is_published ASC"))
    when ["status", "desc"] then order(Arel.sql("articles.is_published DESC"))
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
    self.published_at = Article::PublishedAtNormalizer.call(published_at)
  end

  def autoset_published_at
    if is_published?
      self.published_at = Time.current if published_at.blank?
    else
      self.published_at = nil
    end
  end

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

  def image_presence
    # If the form requested removal, allow no attachment
    return if remove_image.present?

    errors.add(:image, "must be attached") unless image.attached?
  end
end
