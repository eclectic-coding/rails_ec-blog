class AddArticleToProjects < ActiveRecord::Migration[8.1]
  def change
    add_reference :projects, :article, null: true, foreign_key: true
  end
end
