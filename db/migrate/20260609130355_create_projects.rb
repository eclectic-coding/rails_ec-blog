class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.text :description
      t.string :url, null: false
      t.string :source_url
      t.string :project_type, null: false
      t.string :rubygem_name
      t.string :version
      t.boolean :is_featured, null: false, default: false
      t.integer :position
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :projects, :project_type
    add_index :projects, :rubygem_name, unique: true, where: "rubygem_name IS NOT NULL"
    add_index :projects, :position
  end
end
