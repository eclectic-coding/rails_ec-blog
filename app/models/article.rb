# == Schema Information
#
# Table name: articles
#
#  id           :integer          not null, primary key
#  title        :string
#  content      :text
#  is_published :boolean          default(FALSE)
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  published_at :datetime
#
# Indexes
#
#  index_articles_on_published_at  (published_at)
#  index_articles_on_user_id       (user_id)
#

class Article < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  scope :published, -> { where(is_published: true) }
  scope :draft, -> { where(is_published: false) }
  scope :recent, -> { order(Arel.sql("COALESCE(published_at, created_at) DESC, created_at DESC")) }

  def to_markdown = content

  def self.visible_to(user)
    if user&.admin?
      all.recent
    else
      published.recent
    end
  end

  # Normalize date-only inputs to beginning_of_day and autoset published_at on publish/unpublish
  before_validation :normalize_published_at
  before_save :autoset_published_at, if: -> { will_save_change_to_is_published? }

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
    end
  end

  def autoset_published_at
    if is_published?
      self.published_at = Time.current if published_at.blank?
    else
      self.published_at = nil
    end
  end
end
