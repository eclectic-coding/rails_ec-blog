class ReplacePublishedDateAndTimeWithPublishedAt < ActiveRecord::Migration[8.1]
  def up
    # Add the new datetime column
    unless column_exists?(:articles, :published_at)
      add_column :articles, :published_at, :datetime
    end

    # Backfill published_at from published_date + published_time (use midnight when time is NULL)
    execute <<-SQL.squish
      UPDATE articles
      SET published_at = (published_date::timestamp + COALESCE(published_time, '00:00:00'::time))
      WHERE published_date IS NOT NULL;
    SQL

    # Remove the old columns if they exist
    if column_exists?(:articles, :published_time)
      remove_column :articles, :published_time
    end

    if column_exists?(:articles, :published_date)
      remove_column :articles, :published_date
    end
  end

  def down
    # Recreate the old columns
    unless column_exists?(:articles, :published_date)
      add_column :articles, :published_date, :date
    end

    unless column_exists?(:articles, :published_time)
      add_column :articles, :published_time, :time
    end

    # Populate them from published_at
    execute <<-SQL.squish
      UPDATE articles
      SET published_date = published_at::date, published_time = published_at::time
      WHERE published_at IS NOT NULL;
    SQL

    # Remove the published_at column
    if column_exists?(:articles, :published_at)
      remove_column :articles, :published_at
    end
  end
end

