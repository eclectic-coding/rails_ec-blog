class AddIndexToArticlesPublishedAt < ActiveRecord::Migration[8.1]
  def change
    # Add an index to speed up sorting/filtering by published_at
    unless index_exists?(:articles, :published_at)
      add_index :articles, :published_at
    end
  end
end

