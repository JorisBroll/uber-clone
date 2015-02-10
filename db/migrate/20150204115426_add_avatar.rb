class AddAvatar < ActiveRecord::Migration
  def change
  	remove_column :users, :photo
  	add_attachment :users, :photo
  end
end
