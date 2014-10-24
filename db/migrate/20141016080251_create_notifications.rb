class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :content
      t.boolean :seen
      t.integer :user_id

      t.timestamps
    end
  end
end
