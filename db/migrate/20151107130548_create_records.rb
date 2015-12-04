class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.string :url
      t.text :keywords
      t.string :searchengine
      t.integer :ranking
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :records, [:user_id, :created_at]
  end
end
