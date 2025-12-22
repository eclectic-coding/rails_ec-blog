class RenamePublishedAtToPublishedDateAndAddPublishedTime < ActiveRecord::Migration[8.1]
  def up
    # Rename existing published_at (date) to published_date
    if column_exists?(:articles, :published_at)
      rename_column :articles, :published_at, :published_date
    end

    # Add published_time to store the time-of-day when published
    unless column_exists?(:articles, :published_time)
      add_column :articles, :published_time, :time
    end
  end

  def down
    if column_exists?(:articles, :published_time)
      remove_column :articles, :published_time
    end

    if column_exists?(:articles, :published_date)
      rename_column :articles, :published_date, :published_at
    end
  end
end

