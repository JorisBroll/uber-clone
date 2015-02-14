class SetFacebookIdType < ActiveRecord::Migration
  def change
  	remove_column :users, :facebookID
  	add_column :users, :facebookID, :string
  end
end
