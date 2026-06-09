class Project < ApplicationRecord
  TYPES = %w[rubygem github npm other].freeze

  validates :name, presence: true
  validates :url, presence: true
  validates :project_type, inclusion: { in: TYPES }
  validates :rubygem_name, uniqueness: true, allow_nil: true

  scope :featured, -> { where(is_featured: true) }
  scope :by_position, -> { order(Arel.sql("position IS NULL, position ASC")) }
  scope :featured_first, -> { order(is_featured: :desc).by_position }

  def rubygem?
    project_type == "rubygem"
  end
end
