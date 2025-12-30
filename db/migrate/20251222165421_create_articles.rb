class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :content
      t.datetime :published_at
      t.boolean :is_published, default: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
