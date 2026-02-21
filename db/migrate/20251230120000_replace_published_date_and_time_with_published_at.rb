class ReplacePublishedDateAndTimeWithPublishedAt < ActiveRecord::Migration[8.1]
  def up
    # Add the new datetime column
    unless column_exists?(:articles, :published_at)
      add_column :articles, :published_at, :datetime
    end

    # Backfill published_at from published_date + published_time (use midnight when time is NULL)
    Article.reset_column_information
    Article.find_each do |article|
      if article.published_date.present?
        time = article.published_time || Time.zone.parse('00:00:00')
        datetime = article.published_date.to_datetime + time.seconds_since_midnight.seconds
        article.update_column(:published_at, datetime)
      end
    end

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
    Article.reset_column_information
    Article.find_each do |article|
      if article.published_at.present?
        article.update_columns(
          published_date: article.published_at.to_date,
          published_time: article.published_at
        )
      end
    end

    # Remove the published_at column
    if column_exists?(:articles, :published_at)
      remove_column :articles, :published_at
    end
  end
end

