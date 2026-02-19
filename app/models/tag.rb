# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#

class Tag < ApplicationRecord
  has_many :article_tags, dependent: :destroy
  has_many :articles, through: :article_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :normalize_name

  scope :ordered, -> { order(:name) }

  # Use tag name in URLs instead of ID, with hyphens for spaces
  def to_param
    name.gsub(' ', '-')
  end

  # Find tag by slug (hyphenated name) or regular name
  def self.find_by_param(param)
    find_by(name: param.gsub('-', ' '))
  end

  private

  def normalize_name
    self.name = name.downcase.strip if name.present?
  end
end
