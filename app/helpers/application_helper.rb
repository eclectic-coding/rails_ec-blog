module ApplicationHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      "alert-success"
    when :error
      "alert-danger"
    when :alert
      "alert-warning"
    when :notice
      "alert-info"
    else
      flash_type.to_s
    end
  end

  def bootstrap_toast_class_for(flash_type)
    bootstrap_class_for(flash_type).sub('alert-', 'text-bg-')
  end

  # Returns a friendly application title, e.g. "RailsBlog" -> "Rails Blog"
  def app_title
    Rails.application.class.module_parent_name.to_s
      .gsub(/([a-z\d])([A-Z])/, '\1 \2')
      .humanize
      .titleize
      .presence || "Application"
  end

  # Generates a preview of article content from ActionText rich text
  def article_preview(content, length: 200)
    return "" if content.blank?

    # If content is an ActionText::RichText object, get its plain text
    text = if content.respond_to?(:to_plain_text)
             content.to_plain_text
    else
             content.to_s
    end

    # Clean up extra whitespace
    text = text.gsub(/\n+/, ' ').strip.squeeze(' ')

    # Truncate to desired length
    if text.length > length
      text.truncate(length, separator: ' ', omission: '...')
    else
      text
    end
  end
end
