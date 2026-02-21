class ChangePublishedAtToDateOnArticles < ActiveRecord::Migration[8.1]
  def up
    # SQLite doesn't support the :using option, so we:
    # 1. Add a temporary column
    # 2. Copy the data (Rails will handle the conversion)
    # 3. Remove the old column
    # 4. Rename the temporary column
    add_column :articles, :published_at_temp, :date

    # Copy data, converting datetime to date
    Article.reset_column_information
    Article.find_each do |article|
      if article.published_at.present?
        article.update_column(:published_at_temp, article.published_at.to_date)
      end
    end

    remove_column :articles, :published_at
    rename_column :articles, :published_at_temp, :published_at
  end

  def down
    # NOTE: This rollback involves irreversible data loss. The `up` migration
    # converted datetime values to dates, discarding the original time component.
    # Rolling back restores a datetime column, but all times will be set to
    # midnight (00:00:00) since the original time information is no longer available.
    add_column :articles, :published_at_temp, :datetime

    Article.reset_column_information
    Article.find_each do |article|
      if article.published_at.present?
        article.update_column(:published_at_temp, article.published_at.to_datetime)
      end
    end

    remove_column :articles, :published_at
    rename_column :articles, :published_at_temp, :published_at
  end
end
