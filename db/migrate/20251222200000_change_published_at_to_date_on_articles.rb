class ChangePublishedAtToDateOnArticles < ActiveRecord::Migration[8.1]
  def up
    change_column :articles, :published_at, :date, using: 'published_at::date'
  end

  def down
    change_column :articles, :published_at, :datetime, using: 'published_at::timestamp'
  end
end
