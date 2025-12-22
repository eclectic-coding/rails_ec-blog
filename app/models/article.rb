# == Schema Information
#
# Table name: articles
#
#  id             :integer          not null, primary key
#  title          :string
#  content        :text
#  published_date :date
#  is_published   :boolean          default(FALSE)
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  published_time :time
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#

class Article < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  scope :published, -> { where(is_published: true) }
  scope :draft, -> { where(is_published: false) }
  scope :recent, -> { order(Arel.sql("COALESCE(published_date, created_at::date) DESC, COALESCE(published_time, created_at::time) DESC, created_at DESC")) }

  def self.visible_to(user)
    if user&.admin?
      all.recent
    else
      published.recent
    end
  end

  def published_at
    return nil if published_date.nil?
    published_date
  end

  def published_at=(value)
    if value.nil?
      self.published_date = nil
      self.published_time = nil
      return
    end

    case value
    when String
      # Prefer parsing Date strings for compatibility; if it contains time, parse and extract date/time
      parsed_time = Time.zone.parse(value) rescue nil
      if parsed_time
        self.published_date = parsed_time.to_date
        # set published_time only if the string contained a time component (heuristic)
        if value.match(/\d:\d/)
          self.published_time = parsed_time.to_time
        end
      else
        self.published_date = Date.parse(value) rescue nil
      end
    when Date
      self.published_date = value
    when Time, DateTime, ActiveSupport::TimeWithZone
      tz_time = value.in_time_zone
      self.published_date = tz_time.to_date
      self.published_time = tz_time.to_time
    else
      if value.respond_to?(:to_date)
        self.published_date = value.to_date
      end
      if value.respond_to?(:to_time)
        self.published_time = value.to_time
      end
    end
  end

  # When publishing/unpublishing we set/clear the date and time.
  before_save :autoset_published_date_and_time, if: -> { will_save_change_to_is_published? }

  private

  def autoset_published_date_and_time
    if is_published?
      self.published_date = Date.current if published_date.blank?
      self.published_time = Time.current if published_time.blank?
    else
      self.published_date = nil
      self.published_time = nil
    end
  end
end
