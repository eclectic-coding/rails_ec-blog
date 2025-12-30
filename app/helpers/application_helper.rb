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
end
