require "rails_helper"

RSpec.describe MissingActionTextAttachmentsValidator do
  let(:user)    { build_stubbed(:user) }
  let(:article) { build(:article, user: user, content: "Some text") }

  def stub_body(attachments:, present: true)
    body_double = double("ActionText::Content", present?: present, attachments: attachments)
    allow(article).to receive_message_chain(:content, :body).and_return(body_double)
  end

  it "is valid when content body is blank" do
    stub_body(attachments: [], present: false)
    article.valid?
    expect(article.errors[:content]).to be_empty
  end

  it "is valid when content has no attachments" do
    stub_body(attachments: [])
    article.valid?
    expect(article.errors[:content]).to be_empty
  end

  it "is valid when no attachment is a MissingAttachable" do
    attachment = double("ActionText::Attachment", attachable: double("SomeBlob"))
    stub_body(attachments: [attachment])
    article.valid?
    expect(article.errors[:content]).to be_empty
  end

  it "adds an error when content contains a MissingAttachable node" do
    missing    = ActionText::Attachables::MissingAttachable.new("unresolvable-sgid")
    attachment = double("ActionText::Attachment", attachable: missing)
    stub_body(attachments: [attachment])

    article.valid?

    expect(article.errors[:content]).to include(
      a_string_matching(/embedded image that could not be processed/)
    )
  end

  it "adds only one error even when multiple MissingAttachable nodes are present" do
    missing = ActionText::Attachables::MissingAttachable.new("sgid")
    stub_body(attachments: Array.new(3) { double("attachment", attachable: missing) })

    article.valid?

    expect(article.errors[:content].count).to eq(1)
  end

  it "logs a warning and does not raise when the attachment check errors" do
    body_double = double("ActionText::Content", present?: true)
    allow(body_double).to receive(:attachments).and_raise(StandardError, "something unexpected")
    allow(article).to receive_message_chain(:content, :body).and_return(body_double)
    allow(Rails.logger).to receive(:warn)

    expect { article.valid? }.not_to raise_error
    expect(Rails.logger).to have_received(:warn).with(/MissingActionTextAttachmentsValidator/)
  end
end