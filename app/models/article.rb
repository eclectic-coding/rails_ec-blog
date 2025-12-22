# == Schema Information
#
# Table name: articles
#
#  id           :integer          not null, primary key
#  title        :string
#  content      :text
#  published_at :date
#  is_published :boolean          default(FALSE)
#  user_id      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
  scope :recent, -> { order(Arel.sql("COALESCE(published_at, created_at) DESC")) }

  def self.visible_to(user)
    if user&.admin?
      all.recent
    else
      published.recent
    end
  end

  before_save :autoset_published_at, if: -> { will_save_change_to_is_published? }

  private

  def autoset_published_at
    if is_published?
      # For a date column we should set a Date (no time component)
      self.published_at = Date.current if published_at.blank?
    else
      self.published_at = nil
    end
  end
end
