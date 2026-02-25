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
  def article_preview(content, length: 50)
    return "" if content.blank?

    # If content is an ActionText::RichText object, get its plain text
    text = if content.respond_to?(:to_plain_text)
             content.to_plain_text
    else
             content.to_s
    end

    # Strip fenced code blocks (``` ... ```) including their content
    text = text.gsub(/```[\s\S]*?```/, "")

    # Strip inline code (`...`)
    text = text.gsub(/`[^`]*`/, "")

    # Strip markdown headers (# Heading) — handle both line-start and mid-string after join
    text = text.gsub(/(?:^|\s)#+\s+/, " ").lstrip

    # Strip markdown links — keep the display text, drop the URL
    text = text.gsub(/\[([^\]]*)\]\([^)]*\)/, '\1')

    # Strip bold (**text**) and italic (*text*) markers
    text = text.gsub(/\*{1,2}([^*]*)\*{1,2}/, '\1')

    # Clean up extra whitespace and newlines
    text = text.gsub(/\n+/, " ").strip.squeeze(" ")

    # Truncate to desired length
    if text.length > length
      text.truncate(length, separator: " ", omission: "...")
    else
      text
    end
  end
end
