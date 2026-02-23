class MigrateArticleContentToActionText < ActiveRecord::Migration[8.1]
  def up
    # Migrate existing content to ActionText
    say_with_time "Migrating article content to ActionText" do
      require 'redcarpet'

      # Configure Redcarpet with common options
      markdown = Redcarpet::Markdown.new(
        Redcarpet::Render::HTML.new(
          hard_wrap: true,
          filter_html: false
        ),
        autolink: true,
        fenced_code_blocks: true,
        strikethrough: true,
        superscript: true,
        tables: true
      )

      Article.find_each do |article|
        old_content = article.read_attribute_before_type_cast(:content)
        next if old_content.blank?

        # Parse markdown to HTML
        html_content = markdown.render(old_content)

        # Update the ActionText content (don't change updated_at)
        article.update_columns(updated_at: article.updated_at)
        article.content.body = html_content
        article.content.save!
      end
    end

    # Remove the old content column
    remove_column :articles, :content, :text
  end

  def down
    # Add back the content column
    add_column :articles, :content, :text

    # Copy ActionText content back
    Article.reset_column_information
    Article.find_each do |article|
      if article.content.present?
        article.update_column(:content, article.content.to_plain_text)
      end
    end
  end
end
