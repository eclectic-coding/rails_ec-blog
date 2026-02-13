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

  # Returns a friendly application title, e.g. "RailsBlog" -> "Rails Blog"
  def app_title
    Rails.application.class.module_parent_name.to_s
      .gsub(/([a-z\d])([A-Z])/, '\1 \2')
      .humanize
      .titleize
      .presence || "Application"
  end

  # Generates a preview of article content, removing code blocks and truncating to specified length
  def article_preview(content, length: 200)
    return "" if content.blank?

    # Remove code blocks (fenced with ``` or indented)
    # Remove fenced code blocks (```...```)
    text_without_code = content.gsub(/```[\s\S]*?```/, '')

    # Remove indented code blocks (4 spaces or tab at start of line)
    text_without_code = text_without_code.gsub(/^([ ]{4}|\t).*$/, '')

    # Remove inline code (`...`)
    text_without_code = text_without_code.gsub(/`[^`]*`/, '')

    # Remove markdown headers, links, bold, italic formatting
    text_without_code = text_without_code.gsub(/#+\s*/, '')  # Headers
    text_without_code = text_without_code.gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')  # Links
    text_without_code = text_without_code.gsub(/[*_]{1,2}([^*_]+)[*_]{1,2}/, '\1')  # Bold/Italic

    # Clean up extra whitespace
    text_without_code = text_without_code.gsub(/\n+/, ' ').strip.squeeze(' ')

    # Truncate to desired length
    if text_without_code.length > length
      text_without_code.truncate(length, separator: ' ', omission: '...')
    else
      text_without_code
    end
  end
end
