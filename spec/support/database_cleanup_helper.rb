RSpec.shared_context "database cleanup" do
  def purge_all_records
    Session.delete_all
    ActionText::RichText.delete_all
    ActiveStorage::Attachment.delete_all
    ActiveStorage::Blob.delete_all
    ArticleTag.delete_all
    Article.delete_all
    Tag.delete_all
    User.delete_all
  end
end