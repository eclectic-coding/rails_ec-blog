class Project < ApplicationRecord
  TYPES = %w[rubygem github npm other].freeze

  belongs_to :article, optional: true

  SAFE_URL_PATTERN = /\Ahttps?:\/\/.+\z/i

  validates :name, presence: true
  validates :url, presence: true, format: { with: SAFE_URL_PATTERN, message: "must start with http:// or https://" }
  validates :source_url, format: { with: SAFE_URL_PATTERN, message: "must start with http:// or https://" }, allow_blank: true
  validates :project_type, inclusion: { in: TYPES }
  validates :rubygem_name, uniqueness: true, allow_nil: true

  scope :featured, -> { where(is_featured: true) }
  scope :by_position, -> { order(Arel.sql("position IS NULL, position ASC")) }
  scope :featured_first, -> { order(is_featured: :desc).by_position }

  def rubygem?
    project_type == "rubygem"
  end
end
