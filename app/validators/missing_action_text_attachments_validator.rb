class MissingActionTextAttachmentsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    body = value.body
    return unless body.present?

    body.attachments.each do |attachment|
      next unless attachment.attachable.is_a?(ActionText::Attachables::MissingAttachable)

      record.errors.add(attribute,
        "contains an embedded image that could not be processed. " \
        "Please remove inline images from your pasted content and use " \
        "the image upload button instead.")
      return
    end
  rescue => e
    Rails.logger.warn(
      "[MissingActionTextAttachmentsValidator] #{record.class}##{attribute}: " \
      "#{e.class}: #{e.message}\n#{Array(e.backtrace).first(5).join("\n")}"
    )
  end
end
